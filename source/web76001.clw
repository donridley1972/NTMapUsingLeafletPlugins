

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76001.INC'),ONCE        !Local module procedure declarations
                     END


LoginForm            PROCEDURE  (NetWebServerWorker p_web,long p_stage=0)
! the 'pre' routines are called when the form _opens_
! the 'post' routines are called when the 'save' or 'cancel' or 'delete' button is pressed
! remember this will happen on 2 separate threads. So use the SessionQueue here
! if you want to carry information from the pre, to the post, stage.

! there are many stages in the form
!   NET:WEB:StagePre which is called when the form _opens_
!   NET:WEB:StageValidate which is called when the form _closes_, before the record is written
!   NET:WEB:StagePost which is called _after_ the record is written
Ans                  LONG                                  !
Loc:Login            STRING(255)                           !
Loc:Password         STRING(255)                           !
Loc:Remember         LONG                                  !
loc:Hash             LONG                                  !
FilesOpened       Long
FilesErrorOnOpen  StringTheory
Loc:Login:IsInvalid  Long
Loc:Password:IsInvalid  Long
Loc:Remember:IsInvalid  Long
loc:Hash:IsInvalid  Long
loc:TabStyle               Long
loc:WebStyle               Long,over(loc:TabStyle)   ! backward compatibility with old embed code
loc:TabTo                  Long
loc:viewonly               Long
loc:silent                 Long
loc:LayoutMethod           Long
loc:formname               string(252)
loc:procedure              string(252)
loc:formaction             string(252)
loc:formactioncancel       string(252)
loc:formactioncanceltarget string(252)
loc:formactiontarget       string(252)
loc:extra                  string(ExtraStringSize)
loc:capture                long
loc:AcceptTypes            String(252)
loc:autocomplete           String(30)
loc:enctype                string(252)
loc:javascript             string(JavascriptStringLen)
loc:tabs                   string(252)
loc:readonly               String(32)
loc:lookuponly             String(32)
loc:invalid                String(100)
loc:alert                  String(1024)
loc:comment                String(1024)
loc:prompt                 String(1024)
loc:invalidtab             Long
loc:tabnumber              Long
loc:retrying               Long
loc:lookupdone             Long
loc:tabheight              Long
loc:action                 string(40)
loc:act                    Long
loc:width                  String(40)
loc:rowstyle               String(252)
loc:buttonset              String(64)
loc:even                   Long
loc:columncounter          Long
loc:maxcolumns             Long
loc:rowstarted             Long
loc:cellstarted            Long
loc:FirstInCell            Long
loc:options                StringTheory ! options for jQuery calls
loc:Random               StringTheory ! for generating Random strings.
loc:popup                  long
loc:inNetWebPopup          long
loc:poppedup               long
loc:ok                     long
loc:parent                 string(252)   ! should always be a lower-case string
loc:Heading                string(1024)
loc:fieldclass             string(StyleStringSize)
loc:frontloading           long
loc:noFocus                long
loc:FormOnSave             long
loc:AutoSave               long
packet                       StringTheory
  CODE
  loc:procedure = lower('LoginForm')
  GlobalErrors.SetProcedureName('LoginForm')
  if p_stage = 0 and p_web.GetValue('_CallPopups') <> 0
    p_stage = Net:Web:Popup ! required for forms in DLL's, where PreCall doesn't know it's a form.
  elsif p_stage = 0 and p_Web.Ajax = 1
    case lower(p_web.Event)
    of 'gainfocus'
      p_stage = Net:Web:FocusBack
    of 'parentupdated'
      loc:noFocus = true ! the form regenerates, but nothing gets focus.
    of 'populatetree'
      p_stage = Net:Web:Populate
    end
  end
  loc:formname = lower('LoginForm_frm')
  loc:parent = p_web.PlainText(lower(p_web.GetValue('_parentProc_')))
  loc:popup = p_web.GetValue('_popup_')
  loc:FormOnSave = Net:CloseForm
  loc:silent = p_web.GetValue('_silent_')

  loc:LayoutMethod =  p_web.site.FormLayoutMethod

  loc:TabStyle = Net:Web:Rounded
  do SetAction
  ans = band(p_stage,255)
  case p_stage
  of net:web:Generate
    do OpenFiles
    if loc:silent = false
      if p_web.Event = 'parentnewselection' or  p_web.GetValue('LoginForm:parentIs') = 'Browse' ! allow for form used as a child of a browse, default to change mode.
        p_web.FormReady('LoginForm','Change')
      Else
        p_web.FormReady('LoginForm','')
      End
    End
    if p_web.site.frontloaded and p_web.Ajax and loc:popup = 1
      loc:FrontLoading = net:GeneratingData
    else
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('LoginForm')
        p_web.DivHeader(p_web.site.ContentBody,p_web.site.contentbodydivclass)
      End
      p_web.DivHeader('LoginForm',p_web.combine(p_web.site.style.formdiv,' nt-fix-center nt-width-300px'))
      p_web.DivHeader('LoginForm_alert',p_web.combine(p_web.site.MessageClass,' nt-hidden'))
      p_web.DivFooter()
    End
    do PreUpdate
    do SetPics
    if loc:FrontLoading = net:GeneratingData
      do GenerateData
    else
      do GenerateForm
      p_web.DivFooter()
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('LoginForm')
        p_web.DivFooter()
      End
    End
  of Net:Web:SetPics
    do StoreMem
    do SetPics
  of Net:Web:SetPics + NET:WEB:StageValidate
    do SetPics

  of Net:Web:MakeReady

  of Net:Web:Init
  orof Net:Web:Init + Net:InsertRecord
  orof Net:Web:Init + Net:ChangeRecord
  orof Net:Web:Init + Net:CopyRecord
  orof Net:Web:Init + Net:ViewRecord
  orof Net:Web:Init + Net:DeleteRecord
    do StoreMem
    do InitForm

  of Net:Web:FocusBack
    do GotFocusBack

  of net:web:popup
    loc:inNetWebPopup = 1
    loc:poppedup = p_web.GetValue('_LoginForm:_poppedup_')
    if p_web.site.FrontLoaded then loc:popup = 1.
    if loc:poppedup = 0 and p_Web.Ajax = 0
      If p_web.GetPreCall('LoginForm') = 0 and (p_web.GetValue('_CallPopups') = 0 or p_web.GetValue('_CallPopups') = 1)
        p_web.AddPreCall('LoginForm')
        p_web.DivHeader('popup_LoginForm','nt-hidden',,,,1,,,'popup_LoginForm')
        p_web.DivHeader('LoginForm',p_web.combine(p_web.site.style.formdiv,' nt-fix-center nt-width-300px'),,,,1)
        If p_web.site.FrontLoaded
          loc:frontloading = net:GeneratingPage
          do GenerateForm
        End
        p_web.DivFooter()
        p_web.DivFooter(,lower('popup_LoginForm End'))
        do Heading
        loc:options.Free(True)
        p_web.SetOption(loc:options,'close','function(event, ui) {{ ntd.pop(); }')
        p_web.SetOption(loc:options,'autoOpen','false')
        p_web.SetOption(loc:options,'width',600)
        p_web.SetOption(loc:options,'modal','true')
        p_web.SetOption(loc:options,'title',loc:Heading)
        p_web.SetOption(loc:options,'position','{{ my: "top", at: "top+' & clip(15) & '", of: window }')
        If p_web.CanCallAddSec() = net:ok
          p_web.SetOption(loc:options,'addsec','LoginForm')
        Else
          p_web.SetOption(loc:options,'addsec','')
        End
        If p_web.site.DefaultFormOpenAnimation
          p_web.SetOption(loc:options,'show','{{' & clip(p_web.site.DefaultFormOpenAnimation) & '}')
        End
        If p_web.site.DefaultFormCloseAnimation
          p_web.SetOption(loc:options,'hide','{{' & clip(p_web.site.DefaultFormCloseAnimation) & '}')
        End
        p_web.SetOption(loc:options,'closeText',p_web.translate(p_web.site.CloseButton.TextValue))
        p_web.jQuery('#' & lower('popup_LoginForm_div'),'dialog',loc:options,'.removeClass("nt-hidden")')
      End
      do popups ! includes all the other popups dependant on this procedure
      loc:poppedup = 1
      p_web.SetValue('_LoginForm:_poppedup_',1)
    end

  of Net:Web:AfterLookup + Net:Web:Cancel
    loc:LookupDone = 0
    do AfterLookup
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('LoginForm')&'_div'').dialog(''close'');')
    end

  of Net:Web:AfterLookup
    loc:LookupDone = 1
    do AfterLookup

  of Net:Web:Cancel
    do CancelForm
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('LoginForm')&'_div'').dialog(''close'');')
    end

  of Net:InsertRecord + NET:WEB:StagePre
    if p_web._InsertAfterSave = 0
      p_web.setsessionvalue('SaveReferLoginForm',p_web.getPageName(p_web.RequestReferer))
    end
    do PreInsert
  of Net:InsertRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateInsert
  of Net:InsertRecord + NET:WEB:Populate
    do OpenFiles
    do InitForm
    do PreInsert
  of Net:CopyRecord + NET:WEB:StagePre
    p_web.setsessionvalue('SaveReferLoginForm',p_web.getPageName(p_web.RequestReferer))
    do PreCopy
  of Net:CopyRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateCopy
  of Net:CopyRecord + NET:WEB:Populate
    do PreCopy
  of Net:ChangeRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferLoginForm',p_web.getPageName(p_web.RequestReferer))      !
    do PreUpdate
    p_web.SetSessionValue('showtab_LoginForm',0)           !
  of Net:ChangeRecord + NET:WEB:StageValidate
    do RestoreMem
    If false
    ElsIf loc:act = Net:InsertRecord
      do ValidateInsert
    ElsIf loc:act = Net:CopyRecord
      do ValidateCopy
    Else
      do ValidateUpdate
    End
  of Net:ChangeRecord + NET:WEB:StagePost
    do RestoreMem
    do PostWrite
    do PostUpdate
  of Net:ChangeRecord + NET:WEB:Populate
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_LoginForm',0)     !
  of Net:DeleteRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferLoginForm',p_web.getPageName(p_web.RequestReferer))   !
    do PreDelete
  of Net:DeleteRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateDelete
  of Net:ViewRecord + NET:WEB:Populate
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_LoginForm',0)  !

  of Net:ViewRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferLoginForm',p_web.getPageName(p_web.RequestReferer))   !
    do PreUpdate
    p_web.SetSessionValue('showtab_LoginForm',0)    !
  of Net:Web:NextTab
    do NextTab
  of Net:Web:Div
    If p_web.site.FrontLoaded
      loc:frontloading = net:GeneratingData
    End
    do CallDiv
  Of Net:Web:Populate
    do PopulateData

  Else
    ans = 0
  End ! Case
  If Loc:Invalid or Ans = Net:Web:InvalidRecord
    Ans = Net:Web:InvalidRecord
    p_web.requestfilename = p_web.formsettings.parentpage
    If p_web.GetValue('_parentPage') = ''
      p_web.SetValue('_parentPage',p_web.requestfilename)
    End
    If p_web.GetValue('retryfield') = ''
      p_web.SetValue('retryfield',Loc:Invalid)
    End
    p_web.SetSessionValue('showtab_LoginForm',Loc:InvalidTab)   !
  ElsIf band(p_stage,NET:WEB:StageValidate) > 0 and band(p_stage,Net:DeleteRecord) <> Net:DeleteRecord and band(p_stage,Net:WriteMask) > 0 and p_web.Ajax = 1 and loc:popup
    If p_web.IfExistsValue('_stayopen_')
    ! only a partial save, so don't complete the form.
    ElsIf loc:FormOnSave = Net:InsertAgain
      If band(loc:act,Net:InsertRecord) <> Net:InsertRecord
        p_web.script('$(''#popup_'&lower('LoginForm')&'_div'').dialog(''close'');')
      End
    Else
      p_web.script('$(''#popup_'&lower('LoginForm')&'_div'').dialog(''close'');')
    End
  End
  If loc:alert <> ''             !
    p_web.SetAlert(loc:alert, net:Alert + Net:Message,'LoginForm',1)
  End                            !
  do CloseFiles
  GlobalErrors.SetProcedureName()
  return Ans

OpenFiles  ROUTINE
  FilesErrorOnOpen.SetValue('')
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened
     FilesOpened = False
  END

AlertParent  routine
  DATA
parent_       string(100)
parentrid_    string(100)
  CODE
  p_web.pushEvent('childupdated')
  parent_ = p_web.GetValue('_ParentProc_')
  If loc:Parent
    p_web.SetValue('_ParentProc_',loc:parent)
    p_web.AlertParent('LoginForm')
  Elsif p_web.formsettings.parentpage
    parentrid_ = p_web.GetValue('_parentrid_')
    p_web.SetValue('_parentrid_','')
    p_web.SetValue('_ParentProc_',p_web.formsettings.parentpage)
    p_web.AlertParent('LoginForm')
    p_web.SetValue('_ParentProc_','')
    p_web.SetValue('_parentrid_',parentrid_)
  Else
    p_web.AlertParent('LoginForm')
  End
  p_web.SetValue('_ParentProc_',parent_)
  p_web.popEvent()

GotFocusBack  routine
  DATA
loc:Equate  string(252)
loc:Done    long
  CODE

! ---------------------------------------------------------------------------------------------------
! This code runs before the record is loaded. For code after the record is loaded see the PreInsert, PreCopy, PreUpdate and so on
InitForm       Routine
  DATA
LF  &FILE
  CODE
  p_web.SetValue('LoginForm_form:inited_',1)
  p_web.formsettings.file = ''
  p_web.formsettings.key = ''
  do RestoreMem

SetFormSettings  routine
  data
  code
  If p_web.Formstate = ''
    p_web.formsettings.file = ''
    p_web.formsettings.key = ''
    p_web.formsettings.action = Net:ChangeRecord
    clear(p_web.formsettings.recordid)
    clear(p_web.formsettings.FieldName)
    If p_web.GetValue('_parentPage') <> ''
      p_web.formsettings.parentpage = p_web.GetValue('_parentPage')
    else
      p_web.formsettings.parentpage = 'LoginForm'
    end
    p_web.formsettings.proc = 'LoginForm'
    clear(p_web.formsettings.target)
    p_web.FormState = p_web.AddSettings()
  end

CancelForm  Routine
  p_web.SetSessionValue('LoginForm:Active',0)

SendMessage Routine
  p_web.Message('Alert',loc:alert,p_web.site.MessageClass,Net:Send,1)

SetPics  Routine

AfterLookup Routine
  loc:TabNumber = -1
  If  true
    loc:TabNumber += 1
  End ! Tab Condition
  p_web.DeleteValue('LookupField')

StoreMem  Routine
  If p_web.IfExistsValue('Loc:Login') = 0 and p_web.IfExistsSessionValue('Loc:Login') = 0
    p_web.SetSessionValue('Loc:Login',Loc:Login)
  Else
    Loc:Login = p_web.GetSessionValue('Loc:Login')
  End
  If p_web.IfExistsValue('Loc:Password') = 0 and p_web.IfExistsSessionValue('Loc:Password') = 0
    p_web.SetSessionValue('Loc:Password',Loc:Password)
  Else
    Loc:Password = p_web.GetSessionValue('Loc:Password')
  End
  If p_web.IfExistsValue('Loc:Remember') = 0 and p_web.IfExistsSessionValue('Loc:Remember') = 0
    p_web.SetSessionValue('Loc:Remember',Loc:Remember)
  Else
    Loc:Remember = p_web.GetSessionValue('Loc:Remember')
  End
  If p_web.IfExistsValue('loc:Hash') = 0 and p_web.IfExistsSessionValue('loc:Hash') = 0
    p_web.SetSessionValue('loc:Hash',loc:Hash)
  Else
    loc:Hash = p_web.GetSessionValue('loc:Hash')
  End

! RestoreMem primes all the non-file fields with their session value. Useful in Validate and PostAction routines
RestoreMem  Routine
  !FormSource=Memory
  If p_web.IfExistsValue('Loc:Login')
    Loc:Login = p_web.GetValue('Loc:Login')
    p_web.SetSessionValue('Loc:Login',Loc:Login)
  Elsif p_web.IfExistsSessionValue('Loc:Login')
    Loc:Login = p_web.GetSessionValue('Loc:Login')
  End
  If p_web.IfExistsValue('Loc:Password')
    Loc:Password = p_web.GetValue('Loc:Password')
    p_web.SetSessionValue('Loc:Password',Loc:Password)
  Elsif p_web.IfExistsSessionValue('Loc:Password')
    Loc:Password = p_web.GetSessionValue('Loc:Password')
  End
  If p_web.IfExistsValue('Loc:Remember')
    Loc:Remember = p_web.GetValue('Loc:Remember')
    p_web.SetSessionValue('Loc:Remember',Loc:Remember)
  Elsif p_web.IfExistsSessionValue('Loc:Remember')
    Loc:Remember = p_web.GetSessionValue('Loc:Remember')
  End
  If p_web.IfExistsValue('loc:Hash')
    loc:Hash = p_web.GetValue('loc:Hash')
    p_web.SetSessionValue('loc:Hash',loc:Hash)
  Elsif p_web.IfExistsSessionValue('loc:Hash')
    loc:Hash = p_web.GetSessionValue('loc:Hash')
  End

SetAction  routine
  data
  code
  If Band(p_Stage,Net:ViewRecord) = Net:ViewRecord
    Loc:ViewOnly = true
    loc:action = p_web.site.ViewPromptText
    loc:act = Net:ViewRecord
    p_web.SetValue('_viewonly_',1) ! cascade ViewOnly mode to child procedures
    p_web.SetSessionValue('LoginForm_CurrentAction',Net:ViewRecord)
  Else
    Case p_web.GetSessionValue('LoginForm_CurrentAction')
    of Net:InsertRecord
      loc:action = p_web.site.InsertPromptText
      loc:act = Net:InsertRecord
    of Net:CopyRecord
      loc:action = p_web.site.CopyPromptText
      loc:act = Net:CopyRecord
    of Net:ChangeRecord
      loc:action = p_web.site.ChangePromptText
      loc:act = Net:ChangeRecord
    of Net:DeleteRecord
      loc:action = p_web.site.DeletePromptText
      loc:act = Net:DeleteRecord
    of Net:ViewRecord
      Loc:ViewOnly = true
      loc:action = p_web.site.ViewPromptText
      loc:act = Net:ViewRecord
    Else
      loc:action = ''
      loc:act = 0
    End
  End

SetFormAction  routine
  data
  code
  loc:FormAction = p_web.GetValue('onsave')
  If loc:formaction = 'stay'
    loc:FormAction = p_web.Requestfilename
  Else
    loc:formaction = 'IndexPage'
  End
  if p_web.GetValue('_ChainToPage_') <> ''
    loc:formaction = p_web.GetValue('_ChainToPage_')
    p_web.SetSessionValue('LoginForm_ChainTo',loc:FormAction)
    loc:formactiontarget = '_self'
  ElsIf p_web.IfExistsSessionValue('LoginForm_ChainTo')
    loc:formaction = p_web.GetSessionValue('LoginForm_ChainTo')
    loc:formactiontarget = '_self'
  End
  If loc:FormActionTarget = ''
    loc:FormActionTarget = '_self'
  End
  If loc:formaction = ''
    loc:formaction = lower(p_web.getPageName(p_web.RequestReferer))
  End
  loc:FormActionCancel = loc:FormAction
  If loc:FormActionCancelTarget = ''
    loc:FormActionCancelTarget = '_self'
  End
  do SetAction

! front-loaded forms only need the fields updated - not the structure generated.
! this routine is called when loc:frontloaded = net:GeneratingData
GenerateData  routine
  data
loc:send     StringTheory
loc:checked  String(50)
  code
  do Refresh::Loc:Login
  do Refresh::Loc:Password
  do Refresh::Loc:Remember
  do Refresh::loc:Hash
  p_web.Script('$(''#'&clip(loc:formname)&''').find(''#FormState'').val('''&clip(p_web.FormState)&''');' & p_web.CRLF)
  p_web.ntForm(loc:formname,'show')

PopulateData  Routine

GenerateForm  Routine
  data
loc:disabled  Long
loc:pos       Long
  code
  p_web.ClearBrowse('LoginForm')
  do LoadRelatedRecords
  ! change the 'save' button so it says 'login'
  p_web.site.SaveButton.TextValue = 'Login'
  
  ! coming to the login screen automatically logs the user out.
  ! Note that logging out does not delete the session.
  p_web.SetSessionLoggedIn(0)
  
  packet = 'whatever'
  do SetFormAction
  do ntForm
  Loc:Login = p_web.RestoreValue('Loc:Login')
  Loc:Password = p_web.RestoreValue('Loc:Password')
  Loc:Remember = p_web.RestoreValue('Loc:Remember')
  loc:Hash = p_web.RestoreValue('loc:Hash')
  If p_web.IfExistsValue('retryField')
    loc:retrying = 1
  End
  loc:viewonly = Choose(p_web.IfExistsValue('View_btn'),1,loc:viewonly)
  loc:AutoSave = 0
  p_web.SetValue('_viewonly_',loc:viewonly)
  packet.append('<form action="'&clip(loc:formaction)&'" '&clip(loc:enctype)&' method="post" name="'&clip(loc:formname)&'" id="'&clip(loc:formname)&'" target="'&clip(loc:FormActionTarget)&'" onsubmit="osf(this);">' & p_web.CRLF)
  if loc:viewonly and p_web.IfExistsValue('LookupField')
    packet.append(p_web.CreateInput('hidden','LookupField',p_web.GetValue('LookupField'))  & p_web.CRLF)
  end
  packet.append(p_web.CreateInput('hidden','FormState',p_web.FormState, , , , , , , , 'FormState' & p_web.RandomId())  & p_web.CRLF)
  do SendPacket
  do Heading
    Case loc:TabStyle
    of Net:Web:Carousel
      packet.append('<div id="'&  lower('Tab_LoginForm') & '_div" class="' & p_web.combine(p_web.site.style.FormTabOuter,,' nt-tab-carousel') & '">')
    of Net:Web:TaskPanel
    of Net:Web:Wizard
      packet.append(p_web.DivHeader('Tab_LoginForm',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    Else
      packet.append(p_web.DivHeader('Tab_LoginForm',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    End
    Case loc:TabStyle
    of Net:Web:Tab
      packet.append('<ul class="'&p_web.combine(p_web.site.style.FormTabTitle,)&'">'& p_web.CRLF)
      If  true
        packet.append('<li><a href="#' & lower('tab_LoginForm0_div') & '">' & '<div>' & p_web.Translate('Login',true)&'</div></a></li>'& p_web.CRLF) !a
      End ! Tab Condition
      packet.append('</ul>'& p_web.CRLF)
    end
    do SendPacket
  if p_web.event = 'callpopups'
    p_web.PushEvent('callpopups')
  else
    p_web.PushEvent('generate')
  end
  do GenerateTab0
    Case loc:TabStyle
    Of Net:Web:TaskPanel
    Of Net:Web:Carousel
      packet.append('</div><13,10>')
    Else
      packet.append(p_web.DivFooter(Net:NoSend))
    End
  do SendPacket
  p_web.PopEvent()
    loc:disabled = false
      If loc:ViewOnly = 0 and (loc:AutoSave=0)
        If loc:TabStyle = Net:Web:Wizard
          packet.append('<div id="LoginForm_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="LoginForm_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'LoginForm')) !f1
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'LoginForm')) !f2
        End
        loc:javascript = ''
        packet.append(p_web.CreateStdButton('button',Net:Web:SaveButton,loc:formname,,,loc:javascript,,loc:disabled,,'LoginForm',1)) !f3
        packet.append('</div>'  & p_web.CRLF) ! end id="LoginForm_saveset"
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'LoginForm_saveset','controlgroup',loc:options)
        End
      ElsIf loc:ViewOnly = 1 and (loc:AutoSave=0 or loc:Act <> Net:ChangeRecord)
        If loc:TabStyle = Net:Web:Wizard
          packet.append('<div id="LoginForm_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="LoginForm_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'LoginForm')) !f8
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'LoginForm')) !f9
        End
        loc:javascript = ''
        if loc:popup
          loc:javascript = clip(loc:javascript) & 'ntd.close();'
          packet.append(p_web.CreateStdButton('button',Net:Web:CloseButton,loc:formname,,,loc:javascript,,,,'LoginForm')) !f10
        else
          packet.append(p_web.CreateStdButton('submit',Net:Web:CloseButton,loc:formname,loc:formactioncancel,loc:formactioncanceltarget,,,,,'LoginForm')) !f11
        end
        packet.append('</div>' & p_web.CRLF)
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'LoginForm_saveset','controlgroup',loc:options)
        End
      End
  if loc:retrying
    p_web.SetValue('SelectField',clip(loc:formname) & '.' & p_web.GetValue('retryfield'))
  Elsif p_web.IfExistsValue('Select_btn')
  End
    loc:options.Free(True)
    Case loc:TabStyle
    of Net:Web:Accordion
      p_web.SetOption(loc:options,'heightStyle','content')
      p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_LoginForm')>0,p_web.GetSessionValue('showtab_LoginForm'),'0'))
      p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''LoginForm_tabchanged'',$(this).accordion("option","active")); }')
      p_web.jQuery('#' & lower('Tab_LoginForm') & '_div','accordion',loc:options)
    of Net:Web:TaskPanel
    of Net:Web:Tab
      p_web.SetOption(loc:options,'activate','function(event,ui){{TabChanged(''LoginForm_tabchanged'',$(this).tabs("option","active"));}')
      p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_LoginForm')>0,p_web.GetSessionValue('showtab_LoginForm'),'0'))
      p_web.jQuery('#' & lower('Tab_LoginForm') & '_div','tabs',loc:options)
    of Net:Web:Wizard
       p_web.SetOption(loc:options,'procedure',lower('LoginForm'))
       p_web.SetOption(loc:options,'popup',loc:popup)
  
       p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_LoginForm')>0,p_web.GetSessionValue('showtab_LoginForm'),0))
       p_web.SetOption(loc:options,'ntform', '#' & clip(loc:formname))
       p_web.ntWiz('LoginForm',loc:options)
    of Net:Web:Carousel
       p_web.SetOption(loc:options,'id',lower('tab_LoginForm_div'))
       p_web.SetOption(loc:options,'dots','^true')
       p_web.SetOption(loc:options,'autoplay','^false')
       p_web.jQuery('#' & lower('tab_LoginForm_div'),'slick',loc:options)
    end
    do SendPacket
  packet.append('</form>'&p_web.CRLF)
  do SendPacket
  loc:options.Free(True)
  If p_web.CanCallAddSec() = net:ok
    p_web.SetOption(loc:options,'addsec','LoginForm')
  End
  do SendPacket
  If not (p_web.site.FrontLoaded and loc:frontloading = net:GeneratingPage) ! don't want to do popups here if generating in front-loaded mode from net:web:popup stage
    do Popups
  end
  if p_web.Ajax then do AutoLookups.

  do SendPacket

Popups  Routine
  If p_web.Ajax = 0
    p_web.PushEvent('callpopups')
    do AutoLookups
    p_web.AddPreCall('LoginForm')
    p_web.SetValue('_popup_',0)
    p_web.PopEvent()
  End

ntForm Routine
  data
loc:BuildOptions                stringTheory
  code
  p_web.SetOption(loc:options,'id',clip(loc:formname))
  p_web.SetOption(loc:options,'procedure', lower('LoginForm'))
  p_web.SetOption(loc:options,'parent', lower(clip(loc:parent)))
  p_web.SetOption(loc:options,'title',loc:Heading)
  p_web.SetOption(loc:options,'tabType', loc:TabStyle)
  p_web.SetOption(loc:options,'action', loc:formaction)
  p_web.SetOption(loc:options,'actionCancel', loc:formactioncancel)
  p_web.SetOption(loc:options,'actionCancelTarget',loc:formactioncanceltarget)
  p_web.SetOption(loc:options,'actionTarget', loc:formactiontarget)
  p_web.SetOption(loc:options,'confirmText',p_web.translate('Confirm'))
  p_web.SetOption(loc:options,'confirmDeleteMessage',p_web.translate('Are you sure you want to delete this record?'))
  p_web.SetOption(loc:options,'yesDeleteText',p_web.translate('Delete'))
  p_web.SetOption(loc:options,'noDeleteText',p_web.translate('No'))
  p_web.SetOption(loc:options,'confirmDelete',p_web.site.DefaultDeletePrompt)
  p_web.SetOption(loc:options,'confirmCancelMessage',p_web.translate('Are you sure you want to cancel the changes?'))
  p_web.SetOption(loc:options,'yesCancelText',p_web.translate('Cancel'))
  p_web.SetOption(loc:options,'noCancelText',p_web.translate('No'))
  p_web.SetOption(loc:options,'confirmCancel',p_web.site.DefaultCancelPrompt)
  p_web.SetOption(loc:options,'popup', loc:popup)
  p_web.SetOption(loc:options,'focus', p_web.focus)
  p_web.ntForm(loc:formname,loc:options)
  If loc:silent
    p_web.ntForm(loc:formname,'hide')
    ans = 0
  End

AutoLookups  Routine
GenerateTab0  Routine
  If  true
      Case loc:TabStyle
      of Net:Web:Accordion
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-accordion-tab-header',)&'"><div class="nt-flex">' & |
        '<div>' & p_web.Translate('Login')&'</div>' &|
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_LoginForm0',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_LoginForm0_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate('Login')&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_LoginForm0',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_LoginForm0',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_LoginForm0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="0"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_LoginForm0_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-tab-carousel-header',)&'">'&|
          '<div>' & p_web.Translate('Login')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_LoginForm0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-rounded-header ui-corner-all',)&'">' & |
          '<div>' & p_web.Translate('Login')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_LoginForm0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend,,,1) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset"><legend class="'&p_web.combine(' nt-plain-legend',)&'">' & |
          '<div>' & p_web.Translate('Login')&'</div>' & |
          '</legend>' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_LoginForm0',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('LoginForm_container',p_web.combine(,),'300',loc:LayoutMethod))
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Loc:Login_row')) ,p_web.Combine(lower(' LoginForm-Loc:Login-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(' nt-prompt-align-middle',), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypePrompt))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::Loc:Login
        If loc:FirstInCell = 1
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        End
        if loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , p_web.Combine(,), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeValue))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
        end
        do Value::Loc:Login
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Loc:Login
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        if loc:cellstarted
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
        Else
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        End
        loc:rowstarted = 0
        loc:cellstarted = 0
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Loc:Password_row')) ,p_web.Combine(lower(' LoginForm-Loc:Password-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(' nt-prompt-align-middle',), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypePrompt))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::Loc:Password
        If loc:FirstInCell = 1
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        End
        if loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , p_web.Combine(,), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeValue))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
        end
        do Value::Loc:Password
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Loc:Password
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        if loc:cellstarted
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
        Else
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        End
        loc:rowstarted = 0
        loc:cellstarted = 0
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Loc:Remember_row')) ,p_web.Combine(lower(' LoginForm-Loc:Remember-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(' nt-prompt-align-middle',), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypePrompt))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::Loc:Remember
        If loc:FirstInCell = 1
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        End
        if loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , p_web.Combine(,), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeValue))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
        end
        do Value::Loc:Remember
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Loc:Remember
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        if loc:cellstarted
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
        Else
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        End
        loc:rowstarted = 0
        loc:cellstarted = 0
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('loc:Hash_row')) ,p_web.Combine(lower(' LoginForm-loc:Hash-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(' nt-prompt-align-middle',), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypePrompt))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::loc:Hash
        If loc:FirstInCell = 1
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        End
        if loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , p_web.Combine(,), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeValue))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
        end
        do Value::loc:Hash
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::loc:Hash
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
        if loc:cellstarted
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
        Else
          packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        End
        loc:rowstarted = 0
        loc:cellstarted = 0
      do SendPacket
      if loc:rowstarted and loc:cellstarted
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('LoginForm_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('LoginForm_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('LoginForm_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_LoginForm0'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_LoginForm')>0,p_web.GetSessionValue('showtab_LoginForm'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''LoginForm_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_LoginForm0_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_LoginForm0'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_LoginForm0'))
      end
      do SendPacket
  End ! TabCondition
Heading  Routine
  data
loc:disabled  long
  code
  If p_web.GetValue('_title_') <> ''
    loc:Heading = p_web.Translate(p_web.GetValue('_title_'),(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
  Else
    loc:Heading = ''
  End
  If p_web.site.HeaderBackButton and (loc:inNetWebPopup or loc:popup)
    loc:Heading = p_web.AddHeaderBackButton(loc:Heading,,)
  End
  If loc:inNetWebPopup = 1
    exit
  end
  If loc:Heading
    If loc:popup
      p_web.SetPopupDialogHeading('LoginForm',clip(loc:Heading),(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
    Else
      packet.append(lower('<div id="form-access-LoginForm"></div>'))
        p_web.DivHeader('LoginForm_header',p_web.combine(p_web.site.style.formheading,))
        If p_web.CanCallAddSec() = net:ok
          packet.Append(clip(loc:Heading) & '<div data-do="swa" class="nt-sec-key-form-heading">' & p_web.CreateIcon('key',,,net:ui))
        Else
          packet.Append(clip(loc:Heading))
        End
        do SendPacket
        p_web.DivFooter()
    End
  End

Refresh::AllTabs  Routine

Refresh::Loc:Login  Routine
  do Prompt::Loc:Login
  do Value::Loc:Login
  do Comment::Loc:Login

Prompt::Loc:Login  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Login') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Login:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Loc:Login')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Loc:Login')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Loc:Login Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Loc:Login = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
    Loc:Login = p_web.GetValue('Value')
  End
  do ValidateValue::Loc:Login  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Loc:Login   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Loc:Login  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Loc:Login',Loc:Login).

Value::Loc:Login  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Loc:Login') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Login') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Loc:Login = p_web.RestoreValue('Loc:Login')
    do ValidateValue::Loc:Login
    If Loc:Login:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Loc:Login
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,20,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Loc:Login')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Loc:Login'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Loc:Login',p_web.GetSessionValueFormat('Loc:Login'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,,,'Loc:Login',,'imm',,,,'LoginForm')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Loc:Login  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Loc:Login:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Login') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#LoginForm_' & p_web.nocolon('Loc:Login') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Loc:Password  Routine
  do Prompt::Loc:Password
  do Value::Loc:Password
  do Comment::Loc:Password

Prompt::Loc:Password  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Password') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Password:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Loc:Password')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Loc:Password')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Loc:Password Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Loc:Password = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
    Loc:Password = p_web.GetValue('Value')
  End
  do ValidateValue::Loc:Password  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Loc:Password  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Loc:Password',Loc:Password).

Value::Loc:Password  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Loc:Password') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Password') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Loc:Password = p_web.RestoreValue('Loc:Password')
    do ValidateValue::Loc:Password
    If Loc:Password:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Loc:Password
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,20,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Loc:Password')&''').val('''&p_web._jsok(p_web.GetSessionValue('Loc:Password'))&''');')
    Else
      packet.Append(p_web.CreateInput('password','Loc:Password',p_web.GetSessionValue('Loc:Password'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,,,'Loc:Password',,'',,,,'LoginForm')  & p_web.CRLF)
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Loc:Password  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Loc:Password:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Password') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#LoginForm_' & p_web.nocolon('Loc:Password') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Loc:Remember  Routine
  do Prompt::Loc:Remember
  do Value::Loc:Remember
  do Comment::Loc:Remember

Prompt::Loc:Remember  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Remember') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Remember me'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="_'&p_web.nocolon('Loc:Remember')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="_'&p_web.nocolon('Loc:Remember')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Loc:Remember Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Loc:Remember = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value')
    if p_web.GetValue('Value') = ''
      p_web.SetValue('Value',0)
    end
    Loc:Remember = p_web.GetValue('Value')
  End
  do ValidateValue::Loc:Remember  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Loc:Remember   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Loc:Remember  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Loc:Remember',Loc:Remember).

Value::Loc:Remember  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Loc:Remember') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Remember') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formcheckbox,,)
  If loc:retrying
    Loc:Remember = p_web.RestoreValue('Loc:Remember')
    do ValidateValue::Loc:Remember
    If Loc:Remember:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- CHECKBOX --- Loc:Remember
    If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      If p_web.GetSessionValue('Loc:Remember') = true
        p_web.Script('$(''#'&p_web.nocolon('Loc:Remember')&''').checkboxbutton("refresh",1);')
      Else
        p_web.Script('$(''#'&p_web.nocolon('Loc:Remember')&''').checkboxbutton("refresh",0);')
      End
    Else
      loc:javascript = ''  ! MakeFormJavaScript
      loc:readonly = Choose(loc:viewonly,'disabled','')
      If p_web.GetSessionValue('Loc:Remember') = true
        loc:readonly = 'checked ' & loc:readonly
      End
      packet.append(p_web.CreateInput('checkbox','Loc:Remember',clip(true),loc:fieldclass,loc:readonly,'data-true="'& clip(true) & '" data-false="' & clip(false) & '"',,loc:javascript,,,'Loc:Remember',,'imm',,,,'LoginForm',,,'checkboxbutton')  & p_web.CRLF)
        packet.append('<label class="'&clip(loc:FieldClass)&'" for="'&p_web.nocolon('Loc:Remember')&'"'&p_web.CreateTip()&'></label>')
        loc:options.Free(True)
        p_web.SetOption(loc:options,'trueText',p_web.Translate('Yes'))
        p_web.SetOption(loc:options,'falseText',p_web.Translate('No'))
        p_web.SetOption(loc:options,'trueIcon','ui-icon-'&'check')
        p_web.SetOption(loc:options,'falseIcon','ui-icon-'&'close')
        p_web.SetOption(loc:options,'label','null')
        p_web.jQuery('#Loc:Remember','checkboxbutton',loc:options)
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Loc:Remember  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Loc:Remember:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('LoginForm_' & p_web.nocolon('Loc:Remember') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#LoginForm_' & p_web.nocolon('Loc:Remember') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::loc:Hash  Routine
  do Prompt::loc:Hash
  do Value::loc:Hash
  do Comment::loc:Hash

Prompt::loc:Hash  Routine


Validate::loc:Hash Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    loc:Hash = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
    loc:Hash = p_web.GetValue('Value')
  End
  do ValidateValue::loc:Hash  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::loc:Hash  Routine
          If loc:invalid = '' then p_web.SetSessionValue('loc:Hash',loc:Hash).

Value::loc:Hash  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('loc:Hash') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('LoginForm_' & p_web.nocolon('loc:Hash') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Hidden
  If loc:retrying
    loc:Hash = p_web.RestoreValue('loc:Hash')
    do ValidateValue::loc:Hash
    If loc:Hash:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- HIDDEN --- loc:Hash -- loc:Hash
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('loc:Hash')&''').val('''&p_web._jsok(p_web.GetSessionValue('loc:Hash'))&''');')
    else
      packet.append(p_web.CreateInput('hidden','loc:Hash',p_web.GetSessionValue('loc:Hash'))  & p_web.CRLF)
    end
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::loc:Hash  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if loc:Hash:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('LoginForm_' & p_web.nocolon('loc:Hash') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#LoginForm_' & p_web.nocolon('loc:Hash') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

NextTab  routine
  data
  code
  p_web.Ajax = 1
  p_web.PageName = p_web._unEscape(p_web.PageName)

  case lower(p_web.PageName)
  of lower('LoginForm_nexttab_' & 0)
    Loc:Login = p_web.GetSessionValue('Loc:Login')
    do ValidateValue::Loc:Login
    If loc:Invalid
      loc:retrying = 1
      do Value::Loc:Login
      do Comment::Loc:Login ! allows comment style to be updated.
    End
    Loc:Password = p_web.GetSessionValue('Loc:Password')
    do ValidateValue::Loc:Password
    If loc:Invalid
      loc:retrying = 1
      do Value::Loc:Password
      do Comment::Loc:Password ! allows comment style to be updated.
    End
    Loc:Remember = p_web.GetSessionValue('Loc:Remember')
    do ValidateValue::Loc:Remember
    If loc:Invalid
      loc:retrying = 1
      do Value::Loc:Remember
      do Comment::Loc:Remember ! allows comment style to be updated.
    End
    loc:Hash = p_web.GetSessionValue('loc:Hash')
    do ValidateValue::loc:Hash
    If loc:Invalid
      loc:retrying = 1
      do Value::loc:Hash
      do Comment::loc:Hash ! allows comment style to be updated.
    End
    If loc:Invalid then exit.
  End
  p_web.ntWiz('LoginForm','next')

ChangeTab  routine
  p_web.ChangeTab(loc:TabStyle,'LoginForm',loc:TabTo)

TabChanged  routine
  data
TabNumber   Long   !! remember that tabs are numbered from 0
TabHeading  String(252),dim(1)
  code
  tabnumber = p_web.GetValue('_tab_')
  tabheading[1]  = p_web.Translate('Login')
  p_web.SetSessionValue('showtab_LoginForm',tabnumber) !! remember that tabs are numbered from 0

CallDiv    routine
  data
  code
  p_web.Ajax = 1
  p_web.PageName = p_web._unEscape(p_web.PageName)
  case lower(p_web.PageName)
  of lower('LoginForm') & '_tabchanged'
     do TabChanged
  of lower('LoginForm_tab_' & 0)
    do GenerateTab0
  of lower('LoginForm_Loc:Login_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Loc:Login
        do AlertParent
      of 'timer'
        do refresh::Loc:Login
        do AlertParent
      else
        do Value::Loc:Login
      end
  of lower('LoginForm_Loc:Password_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Loc:Password
        do AlertParent
      of 'timer'
        do refresh::Loc:Password
        do AlertParent
      else
        do Value::Loc:Password
      end
  of lower('LoginForm_Loc:Remember_value')
      case p_web.Event ! CheckBox
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Loc:Remember
        do AlertParent
      of 'timer'
        do refresh::Loc:Remember
        do AlertParent
      else
        do Value::Loc:Remember
      end
  of lower('LoginForm_loc:Hash_value')
      case p_web.Event ! Hidden
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::loc:Hash
        do AlertParent
      of 'timer'
        do refresh::loc:Hash
        do AlertParent
      else
        do Value::loc:Hash
      end
  End

SendPacket  routine
  p_web.ParseHTML(packet, 1, 0, NET:NoHeader)
  packet.setvalue('')
! NET:WEB:StagePRE

! ---------------------------------------------------------------------------------------------------------
PreInsert  Routine
  data
  code
  p_web.SetValue('LoginForm_form:ready_',1)
  p_web.SetSessionValue('LoginForm:Active',1)
  p_web.SetSessionValue('LoginForm_CurrentAction',Net:InsertRecord)
  p_web.SetSessionValue('showtab_LoginForm',0)   !
  loc:Hash = random(1,2000000000)
  p_web.SetSessionValue('loc:Hash',loc:Hash)    ! taken from priming tab
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreCopy  Routine
  data
  code
  p_web.SetValue('LoginForm_form:ready_',1)
  p_web.SetSessionValue('LoginForm:Active',1)
  p_web.SetSessionValue('LoginForm_CurrentAction',Net:CopyRecord)
  p_web.SetSessionValue('showtab_LoginForm',0)  !
  ! here we need to copy the non-unique fields across
  loc:Hash = random(1,2000000000)
  p_web.SetSessionValue('loc:Hash',loc:Hash)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
! this code runs After the record is loaded. To run code before, see InitForm Routine
PreUpdate  Routine
  data
loc:offset      Long
  code
  p_web.SetValue('LoginForm_form:ready_',1)
  p_web.SetSessionValue('LoginForm:Active',1)
  p_web.SetSessionValue('LoginForm_CurrentAction',Net:ChangeRecord)
  p_web.SetSessionValue('LoginForm:Primed',0)
  loc:Hash = random(1,2000000000)
  p_web.SetSessionValue('loc:Hash',loc:Hash)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreDelete       Routine
  data
  code
  p_web.SetValue('LoginForm_form:ready_',1)
  p_web.SetSessionValue('LoginForm_CurrentAction',Net:DeleteRecord)
  p_web.SetSessionValue('LoginForm:Primed',0)
  p_web.SetSessionValue('showtab_LoginForm',0)   !
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
LoadRelatedRecords  Routine
  loc:ok = 0
  loc:ok = 0

! ---------------------------------------------------------------------------------------------------------
! copies fields from the Value queue to the File Field.
CompleteForm  Routine
  data
loc:pic   string(40)
  code
  do SetPics
    If  true
          If p_web.IfExistsValue('Loc:Login')
            Loc:Login = p_web.GetValue('Loc:Login')
          End
          If p_web.IfExistsValue('Loc:Password')
            Loc:Password = p_web.GetValue('Loc:Password')
          End
          If p_web.IfExistsValue('Loc:Remember') = 0
            p_web.SetValue('Loc:Remember',false)
            Loc:Remember = false
          Else
            Loc:Remember = p_web.GetValue('Loc:Remember')
          End
          If p_web.IfExistsValue('loc:Hash')
            loc:Hash = p_web.GetValue('loc:Hash')
          End
  End   !tab condition

! NET:WEB:StageVALIDATE
ValidateInsert  Routine
  do CompleteForm
  do ValidateRecord

ValidateCopy  Routine
  do CompleteForm
  do ValidateRecord

ValidateUpdate  Routine
  do CompleteForm
  do ValidateRecord
  ! The HASH test prevents the same form-post from being used "twice".
  ! This improves security on public computers.

  if p_web.GetValue('loc:hash') = p_web.GetSessionValue('loc:hash')

    ! login checking goes here. In this example a simple 'Demo / Demo" login will work. Your app will
    ! probably need a stronger test than that.
    if upper(Loc:Login) = 'DEMO' and upper(Loc:Password) = 'DEMO'
      p_web.ValidateLogin()                   ! this sets the session to "logged in"
      p_web.SetSessionValue('loc:hash',0)         ! clear the hash, so this login can't get "replayed".

      ! set the session level, and any other session variables based on the logged in user.
      p_web.SetSessionLevel(1)

      ! this next bit shows how the login & password can be stored in the browser
      ! so that it is "remembered" for next time
      if loc:remember = 1
        p_web.SetCookie('loc__login',loc:login,today()+30)       ! note the expiry date. It's good
        p_web.SetCookie('loc__password',loc:password,today()+30) ! form to make sure your cookies expire sometime.
      else
        ! don't remember, so clear cookies in browser.
        p_web.DeleteCookie('loc__login')
        p_web.DeleteCookie('loc__password')
      End
    Else
      loc:invalid = 'Loc:Login'
      p_web.SetValue('retry',p_web.site.LoginPage)
      loc:Alert = 'Login Failed. Try Again.'
      p_web.DeleteCookie('loc__login')
      p_web.DeleteCookie('loc__password')
    End
  Else
    p_web.DeleteCookie('loc__login')
    p_web.DeleteCookie('loc__password')
  End
  ! delete the session values, so if the user comes back to the form, the items are not set.
  p_web.deletesessionvalue('loc:login')
  p_web.deletesessionvalue('loc:password')
  p_web.deletesessionvalue('loc:remember')
  p_web.deletevalue('loc:login')
  p_web.deletevalue('loc:password')
  p_web.deletevalue('loc:remember')


ValidateDelete  Routine
  p_web.DeleteSessionValue('LoginForm_ChainTo')
  ! Check for restricted child records

ValidateRecord  Routine
  p_web.DeleteSessionValue('LoginForm_ChainTo')

  ! Then add additional constraints set on the template
  loc:InvalidTab = -1
  ! tab = 1
    If  true
        loc:InvalidTab += 1
        do ValidateValue::Loc:Login
        If loc:Invalid then exit.
        do ValidateValue::Loc:Password
        If loc:Invalid then exit.
        do ValidateValue::Loc:Remember
        If loc:Invalid then exit.
        do ValidateValue::loc:Hash
        If loc:Invalid then exit.
  End ! Tab Condition
  ! The following fields are not on the form, but need to be checked anyway.
! NET:WEB:StagePOST
PostWrite  Routine
  Data
  Code

  p_web.SetSessionValue('LoginForm:Active',0)

PostUpdate      Routine
  Data
  Code
  p_web.SetSessionValue('LoginForm:Primed',0)
  p_web.StoreValue('Loc:Login')
  p_web.StoreValue('Loc:Password')
  p_web.StoreValue('Loc:Remember')
  p_web.StoreValue('loc:Hash')
  p_web.SetSessionValue('LoginForm:Active',0)
