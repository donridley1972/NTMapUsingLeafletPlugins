

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76010.INC'),ONCE        !Local module procedure declarations
                     END


GeneralMap           PROCEDURE  (NetWebServerWorker p_web,long p_stage=0)
! the 'pre' routines are called when the form _opens_
! the 'post' routines are called when the 'save' or 'cancel' or 'delete' button is pressed
! remember this will happen on 2 separate threads. So use the SessionQueue here
! if you want to carry information from the pre, to the post, stage.

! there are many stages in the form
!   NET:WEB:StagePre which is called when the form _opens_
!   NET:WEB:StageValidate which is called when the form _closes_, before the record is written
!   NET:WEB:StagePost which is called _after_ the record is written
Ans                  LONG                                  !
gm:zoom              LONG                                  !
gm:Longitude         STRING(20)                            !
gm:Latitude          STRING(20)                            !
FilesOpened       Long
FilesErrorOnOpen  StringTheory
Accident::State  USHORT
Home:IsInvalid  Long
gm:Latitude:IsInvalid  Long
gm:Longitude:IsInvalid  Long
gm:zoom:IsInvalid  Long
GotoButton:IsInvalid  Long
GeneralMap:IsInvalid  Long
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
  loc:procedure = lower('GeneralMap')
  GlobalErrors.SetProcedureName('GeneralMap')
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
  loc:formname = lower('GeneralMap_frm')
  loc:parent = p_web.PlainText(lower(p_web.GetValue('_parentProc_')))
  loc:popup = p_web.GetValue('_popup_')
  loc:FormOnSave = Net:CloseForm
  loc:silent = p_web.GetValue('_silent_')

  loc:LayoutMethod =  p_web.site.FormLayoutMethod

  loc:TabStyle = Net:Web:None
  do SetAction
  ans = band(p_stage,255)
  case p_stage
  of net:web:Generate
    do OpenFiles
    if loc:silent = false
      if p_web.Event = 'parentnewselection' or  p_web.GetValue('GeneralMap:parentIs') = 'Browse' ! allow for form used as a child of a browse, default to change mode.
        p_web.FormReady('GeneralMap','Change')
      Else
        p_web.FormReady('GeneralMap','')
      End
    End
    if p_web.site.frontloaded and p_web.Ajax and loc:popup = 1
      loc:FrontLoading = net:GeneratingData
    else
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('GeneralMap')
        p_web.DivHeader(p_web.site.ContentBody,p_web.site.contentbodydivclass)
      End
      do SendPacket
      Do EarlyStuff
      do SendPacket
      p_web.DivHeader('GeneralMap',p_web.combine(p_web.site.style.formdiv,))
      p_web.DivHeader('GeneralMap_alert',p_web.combine(p_web.site.MessageClass,' nt-hidden'))
      p_web.DivFooter()
    End
    do PreUpdate
    do SetPics
    if loc:FrontLoading = net:GeneratingData
      do GenerateData
    else
      do GenerateForm
      p_web.DivFooter()
      do SendPacket
      Do LateStuff
      do SendPacket
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('GeneralMap')
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
    loc:poppedup = p_web.GetValue('_GeneralMap:_poppedup_')
    if p_web.site.FrontLoaded then loc:popup = 1.
    if loc:poppedup = 0 and p_Web.Ajax = 0
      If p_web.GetPreCall('GeneralMap') = 0 and (p_web.GetValue('_CallPopups') = 0 or p_web.GetValue('_CallPopups') = 1)
        p_web.AddPreCall('GeneralMap')
        p_web.DivHeader('popup_GeneralMap','nt-hidden',,,,1,,,'popup_GeneralMap')
        p_web.DivHeader('GeneralMap',p_web.combine(p_web.site.style.formdiv,),,,,1)
        If p_web.site.FrontLoaded
          loc:frontloading = net:GeneratingPage
          do GenerateForm
        End
        p_web.DivFooter()
        p_web.DivFooter(,lower('popup_GeneralMap End'))
        do Heading
        loc:options.Free(True)
        p_web.SetOption(loc:options,'close','function(event, ui) {{ ntd.pop(); }')
        p_web.SetOption(loc:options,'autoOpen','false')
        p_web.SetOption(loc:options,'width',900)
        p_web.SetOption(loc:options,'modal','true')
        p_web.SetOption(loc:options,'title',loc:Heading)
        p_web.SetOption(loc:options,'position','{{ my: "top", at: "top+' & clip(15) & '", of: window }')
        If p_web.CanCallAddSec() = net:ok
          p_web.SetOption(loc:options,'addsec','GeneralMap')
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
        p_web.jQuery('#' & lower('popup_GeneralMap_div'),'dialog',loc:options,'.removeClass("nt-hidden")')
      End
      do popups ! includes all the other popups dependant on this procedure
      loc:poppedup = 1
      p_web.SetValue('_GeneralMap:_poppedup_',1)
    end

  of Net:Web:AfterLookup + Net:Web:Cancel
    loc:LookupDone = 0
    do AfterLookup
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('GeneralMap')&'_div'').dialog(''close'');')
    end

  of Net:Web:AfterLookup
    loc:LookupDone = 1
    do AfterLookup

  of Net:Web:Cancel
    do CancelForm
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('GeneralMap')&'_div'').dialog(''close'');')
    end

  of Net:InsertRecord + NET:WEB:StagePre
    if p_web._InsertAfterSave = 0
      p_web.setsessionvalue('SaveReferGeneralMap',p_web.getPageName(p_web.RequestReferer))
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
    p_web.setsessionvalue('SaveReferGeneralMap',p_web.getPageName(p_web.RequestReferer))
    do PreCopy
  of Net:CopyRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateCopy
  of Net:CopyRecord + NET:WEB:Populate
    do PreCopy
  of Net:ChangeRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferGeneralMap',p_web.getPageName(p_web.RequestReferer))      !
    do PreUpdate
    p_web.SetSessionValue('showtab_GeneralMap',0)           !
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
    p_web.SetSessionValue('showtab_GeneralMap',0)     !
  of Net:DeleteRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferGeneralMap',p_web.getPageName(p_web.RequestReferer))   !
    do PreDelete
  of Net:DeleteRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateDelete
  of Net:ViewRecord + NET:WEB:Populate
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_GeneralMap',0)  !

  of Net:ViewRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferGeneralMap',p_web.getPageName(p_web.RequestReferer))   !
    do PreUpdate
    p_web.SetSessionValue('showtab_GeneralMap',0)    !
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
    p_web.SetSessionValue('showtab_GeneralMap',Loc:InvalidTab)   !
  ElsIf band(p_stage,NET:WEB:StageValidate) > 0 and band(p_stage,Net:DeleteRecord) <> Net:DeleteRecord and band(p_stage,Net:WriteMask) > 0 and p_web.Ajax = 1 and loc:popup
    If p_web.IfExistsValue('_stayopen_')
    ! only a partial save, so don't complete the form.
    ElsIf loc:FormOnSave = Net:InsertAgain
      If band(loc:act,Net:InsertRecord) <> Net:InsertRecord
        p_web.script('$(''#popup_'&lower('GeneralMap')&'_div'').dialog(''close'');')
      End
    Else
      p_web.script('$(''#popup_'&lower('GeneralMap')&'_div'').dialog(''close'');')
    End
  End
  If loc:alert <> ''             !
    p_web.SetAlert(loc:alert, net:Alert + Net:Message,'GeneralMap',1)
  End                            !
  do CloseFiles
  GlobalErrors.SetProcedureName()
  return Ans

OpenFiles  ROUTINE
  FilesErrorOnOpen.SetValue('')
  If p_web.OpenFile(Accident) <> 0
    FilesErrorOnOpen.Append('Accident',st:clip,',')
  End
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened
  p_Web.CloseFile(Accident)
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
    p_web.AlertParent('GeneralMap')
  Elsif p_web.formsettings.parentpage
    parentrid_ = p_web.GetValue('_parentrid_')
    p_web.SetValue('_parentrid_','')
    p_web.SetValue('_ParentProc_',p_web.formsettings.parentpage)
    p_web.AlertParent('GeneralMap')
    p_web.SetValue('_ParentProc_','')
    p_web.SetValue('_parentrid_',parentrid_)
  Else
    p_web.AlertParent('GeneralMap')
  End
  p_web.SetValue('_ParentProc_',parent_)
  p_web.popEvent()

GotFocusBack  routine
  DATA
loc:Equate  string(252)
loc:Done    long
  CODE
  loc:Equate = upper(p_web.GetValue('_equate_')) ! which button/map on this form caused the popup to appear
  p_web.DeleteValue('_equate_')
  case loc:Equate
  of upper('GeneralMap')
    do Validate::GeneralMap
    loc:done = 1
  of ''
    case upper(p_web.GetValue('_calledfrom_'))
    end
  end
  If loc:done = 0
    p_web.PushEvent('gainfocus')
    p_web.SetValue('_parentProc_',p_web.SetParent(loc:parent,'GeneralMap'))
    p_web.PopEvent()
  end

! ---------------------------------------------------------------------------------------------------
! This code runs before the record is loaded. For code after the record is loaded see the PreInsert, PreCopy, PreUpdate and so on
InitForm       Routine
  DATA
LF  &FILE
  CODE
  p_web.SetValue('GeneralMap_form:inited_',1)
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
      p_web.formsettings.parentpage = 'GeneralMap'
    end
    p_web.formsettings.proc = 'GeneralMap'
    clear(p_web.formsettings.target)
    p_web.FormState = p_web.AddSettings()
  end

CancelForm  Routine
  p_web.SetSessionValue('GeneralMap:Active',0)

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
  If p_web.IfExistsValue('gm:Latitude') = 0 and p_web.IfExistsSessionValue('gm:Latitude') = 0
    p_web.SetSessionValue('gm:Latitude',gm:Latitude)
  Else
    gm:Latitude = p_web.GetSessionValue('gm:Latitude')
  End
  If p_web.IfExistsValue('gm:Longitude') = 0 and p_web.IfExistsSessionValue('gm:Longitude') = 0
    p_web.SetSessionValue('gm:Longitude',gm:Longitude)
  Else
    gm:Longitude = p_web.GetSessionValue('gm:Longitude')
  End
  If p_web.IfExistsValue('gm:zoom') = 0 and p_web.IfExistsSessionValue('gm:zoom') = 0
    p_web.SetSessionValue('gm:zoom',gm:zoom)
  Else
    gm:zoom = p_web.GetSessionValue('gm:zoom')
  End

! RestoreMem primes all the non-file fields with their session value. Useful in Validate and PostAction routines
RestoreMem  Routine
  !FormSource=Memory
  If p_web.IfExistsValue('gm:Latitude')
    gm:Latitude = p_web.GetValue('gm:Latitude')
    p_web.SetSessionValue('gm:Latitude',gm:Latitude)
  Elsif p_web.IfExistsSessionValue('gm:Latitude')
    gm:Latitude = p_web.GetSessionValue('gm:Latitude')
  End
  If p_web.IfExistsValue('gm:Longitude')
    gm:Longitude = p_web.GetValue('gm:Longitude')
    p_web.SetSessionValue('gm:Longitude',gm:Longitude)
  Elsif p_web.IfExistsSessionValue('gm:Longitude')
    gm:Longitude = p_web.GetSessionValue('gm:Longitude')
  End
  If p_web.IfExistsValue('gm:zoom')
    gm:zoom = p_web.GetValue('gm:zoom')
    p_web.SetSessionValue('gm:zoom',gm:zoom)
  Elsif p_web.IfExistsSessionValue('gm:zoom')
    gm:zoom = p_web.GetSessionValue('gm:zoom')
  End

SetAction  routine
  data
  code
  If Band(p_Stage,Net:ViewRecord) = Net:ViewRecord
    Loc:ViewOnly = true
    loc:action = p_web.site.ViewPromptText
    loc:act = Net:ViewRecord
    p_web.SetValue('_viewonly_',1) ! cascade ViewOnly mode to child procedures
    p_web.SetSessionValue('GeneralMap_CurrentAction',Net:ViewRecord)
  Else
    Case p_web.GetSessionValue('GeneralMap_CurrentAction')
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
    loc:formaction = p_web.getsessionvalue('SaveReferGeneralMap')
  End
  if p_web.GetValue('_ChainToPage_') <> ''
    loc:formaction = p_web.GetValue('_ChainToPage_')
    p_web.SetSessionValue('GeneralMap_ChainTo',loc:FormAction)
    loc:formactiontarget = '_self'
  ElsIf p_web.IfExistsSessionValue('GeneralMap_ChainTo')
    loc:formaction = p_web.GetSessionValue('GeneralMap_ChainTo')
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
  do Refresh::Home
  do Refresh::gm:Latitude
  do Refresh::gm:Longitude
  do Refresh::gm:zoom
  do Refresh::GotoButton
  do Refresh::GeneralMap
  p_web.Script('$(''#'&clip(loc:formname)&''').find(''#FormState'').val('''&clip(p_web.FormState)&''');' & p_web.CRLF)
  p_web.ntForm(loc:formname,'show')

PopulateData  Routine

GenerateForm  Routine
  data
loc:disabled  Long
loc:pos       Long
  code
  p_web.ClearBrowse('GeneralMap')
  do LoadRelatedRecords
  do SetFormAction
  do ntForm
  gm:Latitude = p_web.RestoreValue('gm:Latitude')
  gm:Longitude = p_web.RestoreValue('gm:Longitude')
  gm:zoom = p_web.RestoreValue('gm:zoom')
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
      packet.append('<div id="'&  lower('Tab_GeneralMap') & '_div" class="' & p_web.combine(p_web.site.style.FormTabOuter,,' nt-tab-carousel') & '">')
    of Net:Web:TaskPanel
    of Net:Web:Wizard
      packet.append(p_web.DivHeader('Tab_GeneralMap',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    Else
      packet.append(p_web.DivHeader('Tab_GeneralMap',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    End
    Case loc:TabStyle
    of Net:Web:Tab
      packet.append('<ul class="'&p_web.combine(p_web.site.style.FormTabTitle,)&'">'& p_web.CRLF)
      If  true
        packet.append('<li><a href="#' & lower('tab_GeneralMap0_div') & '">' & '<div>' & p_web.Translate(,true)&'</div></a></li>'& p_web.CRLF) !a
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
          packet.append('<div id="GeneralMap_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="GeneralMap_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'GeneralMap')) !f1
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'GeneralMap')) !f2
        End
        packet.append('</div>'  & p_web.CRLF) ! end id="GeneralMap_saveset"
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'GeneralMap_saveset','controlgroup',loc:options)
        End
      ElsIf loc:ViewOnly = 1 and (loc:AutoSave=0 or loc:Act <> Net:ChangeRecord)
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'GeneralMap')) !f8
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'GeneralMap')) !f9
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
      p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_GeneralMap')>0,p_web.GetSessionValue('showtab_GeneralMap'),'0'))
      p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''GeneralMap_tabchanged'',$(this).accordion("option","active")); }')
      p_web.jQuery('#' & lower('Tab_GeneralMap') & '_div','accordion',loc:options)
    of Net:Web:TaskPanel
    of Net:Web:Tab
      p_web.SetOption(loc:options,'activate','function(event,ui){{TabChanged(''GeneralMap_tabchanged'',$(this).tabs("option","active"));}')
      p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_GeneralMap')>0,p_web.GetSessionValue('showtab_GeneralMap'),'0'))
      p_web.jQuery('#' & lower('Tab_GeneralMap') & '_div','tabs',loc:options)
    of Net:Web:Wizard
       p_web.SetOption(loc:options,'procedure',lower('GeneralMap'))
       p_web.SetOption(loc:options,'popup',loc:popup)
  
       p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_GeneralMap')>0,p_web.GetSessionValue('showtab_GeneralMap'),0))
       p_web.SetOption(loc:options,'ntform', '#' & clip(loc:formname))
       p_web.ntWiz('GeneralMap',loc:options)
    of Net:Web:Carousel
       p_web.SetOption(loc:options,'id',lower('tab_GeneralMap_div'))
       p_web.SetOption(loc:options,'dots','^true')
       p_web.SetOption(loc:options,'autoplay','^false')
       p_web.jQuery('#' & lower('tab_GeneralMap_div'),'slick',loc:options)
    end
    do SendPacket
  packet.append('</form>'&p_web.CRLF)
  do SendPacket
  loc:options.Free(True)
  If p_web.CanCallAddSec() = net:ok
    p_web.SetOption(loc:options,'addsec','GeneralMap')
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
    p_web.AddPreCall('GeneralMap')
    p_web.SetValue('_popup_',0)
    p_web.PopEvent()
  End

ntForm Routine
  data
loc:BuildOptions                stringTheory
  code
  p_web.SetOption(loc:options,'id',clip(loc:formname))
  p_web.SetOption(loc:options,'procedure', lower('GeneralMap'))
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
        '<div>' & p_web.Translate()&'</div>' &|
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_GeneralMap0',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_GeneralMap0_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate()&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_GeneralMap0',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_GeneralMap0',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_GeneralMap0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="0"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_GeneralMap0_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_GeneralMap0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_GeneralMap0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset">' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_GeneralMap0',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('GeneralMap_container',p_web.combine(,),,loc:LayoutMethod))
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Home_row')) ,p_web.Combine(lower(' GeneralMap-Home-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(,),  ,  ,,  , , loc:LayoutMethod,net:CellTypeOnly)) !1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Value::Home
          do Comment::Home
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('gm:Latitude_row')) ,p_web.Combine(lower(' GeneralMap-gm:Latitude-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(,),  ,  ,,  , , loc:LayoutMethod,net:CellTypeOnly)) !1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::gm:Latitude
        do Value::gm:Latitude
          do Comment::gm:Latitude
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('gm:Longitude_row')) ,p_web.Combine(lower(' GeneralMap-gm:Longitude-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(,),  ,  ,,  , , loc:LayoutMethod,net:CellTypeOnly)) !1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::gm:Longitude
        do Value::gm:Longitude
          do Comment::gm:Longitude
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('gm:zoom_row')) ,p_web.Combine(lower(' GeneralMap-gm:zoom-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(,),  ,  ,,  , , loc:LayoutMethod,net:CellTypeOnly)) !1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::gm:zoom
        do Value::gm:zoom
          do Comment::gm:zoom
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('GotoButton_row')) ,p_web.Combine(lower(' GeneralMap-GotoButton-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(,),  ,  ,,  , , loc:LayoutMethod,net:CellTypeOnly)) !1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Value::GotoButton
          do Comment::GotoButton
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('GeneralMap_row')) ,p_web.Combine(lower(' GeneralMap-GeneralMap-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(,),  ,  ,,  , , loc:LayoutMethod,net:CellTypeOnly)) !1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Value::GeneralMap
          do Comment::GeneralMap
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
        packet.append(p_web.FormTableEnd('GeneralMap_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('GeneralMap_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('GeneralMap_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_GeneralMap0'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_GeneralMap')>0,p_web.GetSessionValue('showtab_GeneralMap'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''GeneralMap_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_GeneralMap0_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_GeneralMap0'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_GeneralMap0'))
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
      p_web.SetPopupDialogHeading('GeneralMap',clip(loc:Heading),(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
    Else
      packet.append(lower('<div id="form-access-GeneralMap"></div>'))
        p_web.DivHeader('GeneralMap_header',p_web.combine(p_web.site.style.formheading,))
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

Refresh::Home  Routine
  do Value::Home
  do Comment::Home



Validate::Home Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
  End
  do ValidateValue::Home  ! copies value to session value if valid.
  !! set map to original starting point and zoom
  p_web.Script('$("#' & p_web._jsok(p_web.nocolon('GeneralMap')) & '").ntmap("home");')
  p_web.PushEvent('parentupdated')
  do Refresh::Home   ! Button "Send new value to server"
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Home  Routine

Value::Home  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Home') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.FormButtonDiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('GeneralMap_' & p_web.nocolon('Home') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Button
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- DISPLAY --- or ---- BUTTON --- or --- PROGRESS ----- or --- IMAGE  -- Button
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      exit
    end
    loc:disabled = false
    loc:javascript = ''  ! MakeFormJavaScript
      packet.append(p_web.CreateButton('button','Home','Home',p_web.combine(Choose('Home' <> '','nt-button nt-default-button' & p_web.site.style.FormOtherButtonWithText,p_web.site.style.FormOtherButtonWithOutText),),loc:formname,,,,loc:javascript,loc:disabled,,,,,,1,,,,'nt-left','server','GeneralMap',,,,))!h
    If p_web.Ajax then p_web.ntform(loc:formname,'ready'). ! in case the button was hidden before and now being unhidden by a child procedure and thus form-events not bound to it
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Home  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Home:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('Home') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#GeneralMap_' & p_web.nocolon('Home') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::gm:Latitude  Routine
  do Prompt::gm:Latitude
  do Value::gm:Latitude
  do Comment::gm:Latitude

Prompt::gm:Latitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:Latitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Latitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('gm:Latitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('gm:Latitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::gm:Latitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    gm:Latitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
    gm:Latitude = p_web.GetValue('Value')
  End
  do ValidateValue::gm:Latitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::gm:Latitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::gm:Latitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('gm:Latitude',gm:Latitude).

Value::gm:Latitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('gm:Latitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:Latitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    gm:Latitude = p_web.RestoreValue('gm:Latitude')
    do ValidateValue::gm:Latitude
    If gm:Latitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- gm:Latitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('gm:Latitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('gm:Latitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','gm:Latitude',p_web.GetSessionValueFormat('gm:Latitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,,,'gm:Latitude',,'imm',,,,'GeneralMap')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::gm:Latitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if gm:Latitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:Latitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#GeneralMap_' & p_web.nocolon('gm:Latitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::gm:Longitude  Routine
  do Prompt::gm:Longitude
  do Value::gm:Longitude
  do Comment::gm:Longitude

Prompt::gm:Longitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:Longitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Longitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('gm:Longitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('gm:Longitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::gm:Longitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    gm:Longitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
    gm:Longitude = p_web.GetValue('Value')
  End
  do ValidateValue::gm:Longitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::gm:Longitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::gm:Longitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('gm:Longitude',gm:Longitude).

Value::gm:Longitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('gm:Longitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:Longitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    gm:Longitude = p_web.RestoreValue('gm:Longitude')
    do ValidateValue::gm:Longitude
    If gm:Longitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- gm:Longitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('gm:Longitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('gm:Longitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','gm:Longitude',p_web.GetSessionValueFormat('gm:Longitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,,,'gm:Longitude',,'imm',,,,'GeneralMap')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::gm:Longitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if gm:Longitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:Longitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#GeneralMap_' & p_web.nocolon('gm:Longitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::gm:zoom  Routine
  do Prompt::gm:zoom
  do Value::gm:zoom
  do Comment::gm:zoom

Prompt::gm:zoom  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:zoom') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Zoom:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('gm:zoom')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('gm:zoom')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::gm:zoom Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    gm:zoom = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
    gm:zoom = p_web.GetValue('Value')
  End
  do ValidateValue::gm:zoom  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::gm:zoom   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::gm:zoom  Routine
          If loc:invalid = '' then p_web.SetSessionValue('gm:zoom',gm:zoom).

Value::gm:zoom  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('gm:zoom') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:zoom') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    gm:zoom = p_web.RestoreValue('gm:zoom')
    do ValidateValue::gm:zoom
    If gm:zoom:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- gm:zoom
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,3,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('gm:zoom')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('gm:zoom'))&''');')
    Else
      packet.append(p_web.CreateInput('text','gm:zoom',p_web.GetSessionValueFormat('gm:zoom'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,,,'gm:zoom',,'imm',,,,'GeneralMap')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::gm:zoom  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if gm:zoom:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('gm:zoom') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#GeneralMap_' & p_web.nocolon('gm:zoom') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::GotoButton  Routine
  do Value::GotoButton
  do Comment::GotoButton



Validate::GotoButton Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
  End
  do ValidateValue::GotoButton  ! copies value to session value if valid.
  !! set map to selected position and zoom
  p_web.StoreValue('gm:zoom')
  p_web.StoreValue('gm:Latitude')
  p_web.StoreValue('gm:Longitude')  
  p_web.Script('$("#' & p_web._jsok(p_web.nocolon('GeneralMap')) & '").ntmap("setView",' & p_web.GetSessionValue('gm:Latitude') &',' & p_web.GetSessionValue('gm:Longitude') &',' & p_web.GetSessionValue('gm:zoom') &');')
  p_web.PushEvent('parentupdated')
  do Refresh::GotoButton   ! Button "Send new value to server"
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::GotoButton  Routine

Value::GotoButton  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('GotoButton') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.FormButtonDiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('GeneralMap_' & p_web.nocolon('GotoButton') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Button
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- DISPLAY --- or ---- BUTTON --- or --- PROGRESS ----- or --- IMAGE  -- Button
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      exit
    end
    loc:disabled = false
    loc:javascript = ''  ! MakeFormJavaScript
      packet.append(p_web.CreateButton('button','GotoButton','Go',p_web.combine(Choose('Go' <> '','nt-button nt-default-button' & p_web.site.style.FormOtherButtonWithText,p_web.site.style.FormOtherButtonWithOutText),),loc:formname,,,,loc:javascript,loc:disabled,,,,,,1,,,,'nt-left','server','GeneralMap',,,,))!h
    If p_web.Ajax then p_web.ntform(loc:formname,'ready'). ! in case the button was hidden before and now being unhidden by a child procedure and thus form-events not bound to it
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::GotoButton  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if GotoButton:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('GotoButton') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#GeneralMap_' & p_web.nocolon('GotoButton') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::GeneralMap  Routine
  do Value::GeneralMap
  do Comment::GeneralMap



Validate::GeneralMap Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
  End
  do ValidateValue::GeneralMap  ! copies value to session value if valid.
  ! user just clicked on the map, so move incoming map values to the various session values.
  p_web.StoreValue('gm:zoom','_zoom_')
  p_web.StoreValue('gm:Latitude','_lat_')
  p_web.StoreValue('gm:Longitude','_lng_')
  If loc:invalid = ''
    Case p_web.event
    Of 'zoomed'
    Of 'clicked'
    Of 'gainfocus' ! returned from form
      Case lower(p_web.GetValue('_cluster_'))
      End ! Case lower(p_web.GetValue('_from_'))

    Of 'dragged'  ! marker on map was dragged
      Case lower(p_web.GetValue('_cluster_'))
      End ! Case lower(p_web.GetValue('_cluster_'))
    End
  End
  p_web.PushEvent('parentupdated')
  do SendMessage
  do Refresh::gm:Latitude  !(GenerateFieldReset)
  do Refresh::gm:Longitude  !(GenerateFieldReset)
  do Refresh::gm:zoom  !(GenerateFieldReset)
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::GeneralMap  Routine

Value::GeneralMap  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:url          String(252)
loc:MapProvider  Long
loc:ScaleOptions StringTheory ! options for jQuery calls
loc:MapOptions   StringTheory ! options for jQuery calls
loc:TileOptions  Stringtheory ! options for jQuery calls
loc:MapData      StringTheory
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('GeneralMap') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('GeneralMap_' & p_web.nocolon('GeneralMap') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Map
  If loc:retrying
    do ValidateValue::GeneralMap
    If GeneralMap:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- MAP --- 
    loc:MapProvider = p_web.Site.MapProvider
    loc:url = ''
    packet.append(p_web.CreateMapDiv('GeneralMap',,850,500)  & p_web.CRLF)
    ! Options for the leaflet.js map object
    loc:MapOptions.SetValue('')
    p_web.SetOption(loc:MapOptions,'center','['&p_web.GetLatLng(-34.041) &',' & p_web.GetLatLng(18.47) &']')
    p_web.SetOption(loc:MapOptions,'zoom',p_web.SetMapZoom(loc:MapProvider,14))
    ! Options for the Scale
    loc:ScaleOptions.Free(true)
    p_web.SetOption(loc:ScaleOptions,'maxWidth',300)
    p_web.SetOption(loc:ScaleOptions,'metric',1)
    p_web.SetOption(loc:ScaleOptions,'imperial',0)
    ! options for the leaflet.js tiles layer
    p_web.SetMapDevIdOptions(loc:MapProvider,loc:TileOptions)
    ! options for the nettalk ntmap object (which takes the map and tiles options from above).
    loc:options.Free(True)
    p_web.SetOption(loc:options,'procedure','GeneralMap')
    If p_web.Site.ConnectionSecure
      p_web.SetOption(loc:options,'ssl',1)
    End
    p_web.SetOption(loc:options,'equate','GeneralMap')
    p_web.SetOption(loc:options,'provider',loc:MapProvider)
    p_web.SetOption(loc:options,'divId',p_web.NoColon('GeneralMap'))
    p_web.SetOption(loc:options,'tileURL',loc:url)
    p_web.SetOption(loc:options,'mapOptions',p_web.WrapOptions(loc:mapOptions))
    p_web.SetOption(loc:options,'tileOptions',p_web.WrapOptions(loc:tileOptions))
    p_web.SetOption(loc:options,'scale',1)
    p_web.SetOption(loc:options,'scaleOptions',p_web.WrapOptions(loc:scaleOptions))
    p_web.ntMap('GeneralMap',loc:options)
    ! map marker at start position
    loc:options.Free(True)
    p_web.SetOption(loc:options,'icon','^blueMarker')
    p_web.ntMap('GeneralMap','addMarkerToMap','_home_', p_web.GetLatLng(-34.041) , p_web.GetLatLng(18.47) , p_web.WrapOptions(loc:options) , p_web._jsok('CapeSoft Offices', Net:HtmlOk*0+Net:UnsafeHtmlOk*0) , '1')
  
    !--  Map Data  ---------------------------------------------------
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::GeneralMap  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if GeneralMap:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('GeneralMap_' & p_web.nocolon('GeneralMap') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#GeneralMap_' & p_web.nocolon('GeneralMap') & '_comment_div").html("'&clip(loc:comment)&'");')
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
  of lower('GeneralMap_nexttab_' & 0)
    gm:Latitude = p_web.GetSessionValue('gm:Latitude')
    do ValidateValue::gm:Latitude
    If loc:Invalid
      loc:retrying = 1
      do Value::gm:Latitude
      do Comment::gm:Latitude ! allows comment style to be updated.
    End
    gm:Longitude = p_web.GetSessionValue('gm:Longitude')
    do ValidateValue::gm:Longitude
    If loc:Invalid
      loc:retrying = 1
      do Value::gm:Longitude
      do Comment::gm:Longitude ! allows comment style to be updated.
    End
    gm:zoom = p_web.GetSessionValue('gm:zoom')
    do ValidateValue::gm:zoom
    If loc:Invalid
      loc:retrying = 1
      do Value::gm:zoom
      do Comment::gm:zoom ! allows comment style to be updated.
    End
    If loc:Invalid then exit.
  End
  p_web.ntWiz('GeneralMap','next')

ChangeTab  routine
  p_web.ChangeTab(loc:TabStyle,'GeneralMap',loc:TabTo)

TabChanged  routine
  data
TabNumber   Long   !! remember that tabs are numbered from 0
TabHeading  String(252),dim(1)
  code
  tabnumber = p_web.GetValue('_tab_')
  tabheading[1]  = p_web.Translate()
  p_web.SetSessionValue('showtab_GeneralMap',tabnumber) !! remember that tabs are numbered from 0

CallDiv    routine
  data
  code
  p_web.Ajax = 1
  p_web.PageName = p_web._unEscape(p_web.PageName)
  case lower(p_web.PageName)
  of lower('GeneralMap') & '_tabchanged'
     do TabChanged
  of lower('GeneralMap_tab_' & 0)
    do GenerateTab0
  of lower('GeneralMap_Home_value')
      case p_web.Event ! Button
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Home
        do AlertParent
      of 'timer'
        do refresh::Home
        do AlertParent
      else
        do Value::Home
      end
  of lower('GeneralMap_gm:Latitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::gm:Latitude
        do AlertParent
      of 'timer'
        do refresh::gm:Latitude
        do AlertParent
      else
        do Value::gm:Latitude
      end
  of lower('GeneralMap_gm:Longitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::gm:Longitude
        do AlertParent
      of 'timer'
        do refresh::gm:Longitude
        do AlertParent
      else
        do Value::gm:Longitude
      end
  of lower('GeneralMap_gm:zoom_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::gm:zoom
        do AlertParent
      of 'timer'
        do refresh::gm:zoom
        do AlertParent
      else
        do Value::gm:zoom
      end
  of lower('GeneralMap_GotoButton_value')
      case p_web.Event ! Button
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::GotoButton
        do AlertParent
      of 'timer'
        do refresh::GotoButton
        do AlertParent
      else
        do Value::GotoButton
      end
  of lower('GeneralMap_GeneralMap_value')
      case p_web.Event ! Map
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::GeneralMap
        do AlertParent
      of 'zoomed'
      orof 'moved'
      orof 'dragged'
      orof 'clicked'
        do Validate::GeneralMap
        do AlertParent
      of 'timer'
        do refresh::GeneralMap
        do Refresh::gm:Latitude
        do Refresh::gm:Longitude
        do Refresh::gm:zoom
        do AlertParent
      else
        do Value::GeneralMap
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
  p_web.SetValue('GeneralMap_form:ready_',1)
  p_web.SetSessionValue('GeneralMap:Active',1)
  p_web.SetSessionValue('GeneralMap_CurrentAction',Net:InsertRecord)
  p_web.SetSessionValue('showtab_GeneralMap',0)   !
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreCopy  Routine
  data
  code
  p_web.SetValue('GeneralMap_form:ready_',1)
  p_web.SetSessionValue('GeneralMap:Active',1)
  p_web.SetSessionValue('GeneralMap_CurrentAction',Net:CopyRecord)
  p_web.SetSessionValue('showtab_GeneralMap',0)  !
  ! here we need to copy the non-unique fields across
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
! this code runs After the record is loaded. To run code before, see InitForm Routine
PreUpdate  Routine
  data
loc:offset      Long
  code
  p_web.SetValue('GeneralMap_form:ready_',1)
  p_web.SetSessionValue('GeneralMap:Active',1)
  p_web.SetSessionValue('GeneralMap_CurrentAction',Net:ChangeRecord)
  p_web.SetSessionValue('GeneralMap:Primed',0)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreDelete       Routine
  data
  code
  p_web.SetValue('GeneralMap_form:ready_',1)
  p_web.SetSessionValue('GeneralMap_CurrentAction',Net:DeleteRecord)
  p_web.SetSessionValue('GeneralMap:Primed',0)
  p_web.SetSessionValue('showtab_GeneralMap',0)   !
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
LoadRelatedRecords  Routine
  loc:ok = 0
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
          If p_web.IfExistsValue('gm:Latitude')
            gm:Latitude = p_web.GetValue('gm:Latitude')
          End
          If p_web.IfExistsValue('gm:Longitude')
            gm:Longitude = p_web.GetValue('gm:Longitude')
          End
          If p_web.IfExistsValue('gm:zoom')
            gm:zoom = p_web.GetValue('gm:zoom')
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

ValidateDelete  Routine
  p_web.DeleteSessionValue('GeneralMap_ChainTo')
  ! Check for restricted child records

ValidateRecord  Routine
  p_web.DeleteSessionValue('GeneralMap_ChainTo')

  ! Then add additional constraints set on the template
  loc:InvalidTab = -1
  ! tab = 1
    If  true
        loc:InvalidTab += 1
        do ValidateValue::Home
        If loc:Invalid then exit.
        do ValidateValue::gm:Latitude
        If loc:Invalid then exit.
        do ValidateValue::gm:Longitude
        If loc:Invalid then exit.
        do ValidateValue::gm:zoom
        If loc:Invalid then exit.
        do ValidateValue::GotoButton
        If loc:Invalid then exit.
        do ValidateValue::GeneralMap
        If loc:Invalid then exit.
  End ! Tab Condition
  ! The following fields are not on the form, but need to be checked anyway.
! NET:WEB:StagePOST
PostWrite  Routine
  Data
  Code

  p_web.SetSessionValue('GeneralMap:Active',0)

PostUpdate      Routine
  Data
  Code
  p_web.SetSessionValue('GeneralMap:Primed',0)
  p_web.StoreValue('gm:Latitude')
  p_web.StoreValue('gm:Longitude')
  p_web.StoreValue('gm:zoom')
  p_web.SetSessionValue('GeneralMap:Active',0)
EarlyStuff  Routine
  packet.append(p_web.AsciiToUTF(|
    '<<link href="/styles/L.Control.ZoomBar.css" rel="stylesheet"/><13,10>'&|
    '<<script src="/scripts/L.Control.ZoomBar.js" type="text/javascript"><</script><13,10>'&|
    '',net:OnlyIfUTF,net:StoreAsAscii))
LateStuff  Routine
  packet.append(p_web.AsciiToUTF(|
    '<<script src="/scripts/custom.js" type="text/javascript"><</script><13,10>'&|
    '',net:OnlyIfUTF,net:StoreAsAscii))
