

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76011.INC'),ONCE        !Local module procedure declarations
                     END


UpdateAccident       PROCEDURE  (NetWebServerWorker p_web,long p_stage=0)
! the 'pre' routines are called when the form _opens_
! the 'post' routines are called when the 'save' or 'cancel' or 'delete' button is pressed
! remember this will happen on 2 separate threads. So use the SessionQueue here
! if you want to carry information from the pre, to the post, stage.

! there are many stages in the form
!   NET:WEB:StagePre which is called when the form _opens_
!   NET:WEB:StageValidate which is called when the form _closes_, before the record is written
!   NET:WEB:StagePost which is called _after_ the record is written
Ans                  LONG                                  !
FilesOpened       Long
FilesErrorOnOpen  StringTheory
Accident::State  USHORT
Acc:Description:IsInvalid  Long
Acc:Latitude:IsInvalid  Long
Acc:Longitude:IsInvalid  Long
Acc:Date:IsInvalid  Long
Acc:Time:IsInvalid  Long
Acc:Type:IsInvalid  Long
Acc:markerObject:IsInvalid  Long
Acc:markerOpacity:IsInvalid  Long
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
  loc:procedure = lower('UpdateAccident')
  GlobalErrors.SetProcedureName('UpdateAccident')
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
  loc:formname = lower('UpdateAccident_frm')
  loc:parent = p_web.PlainText(lower(p_web.GetValue('_parentProc_')))
  loc:popup = p_web.GetValue('_popup_')
  loc:FormOnSave = Net:CloseForm
  loc:silent = p_web.GetValue('_silent_')

  loc:LayoutMethod =  p_web.site.FormLayoutMethod

  loc:TabStyle = p_web.site.WebFormStyle
  do SetAction
  ans = band(p_stage,255)
  case p_stage
  of net:web:Generate
    do OpenFiles
    if loc:silent = false
      if p_web.Event = 'parentnewselection' or  p_web.GetValue('UpdateAccident:parentIs') = 'Browse' ! allow for form used as a child of a browse, default to change mode.
        p_web.FormReady('UpdateAccident','Change','Acc:Guid',p_web.GetSessionValue('Acc:Guid'))
      Else
        p_web.FormReady('UpdateAccident','')
      End
    End
    if p_web.site.frontloaded and p_web.Ajax and loc:popup = 1
      loc:FrontLoading = net:GeneratingData
    else
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdateAccident')
        p_web.DivHeader(p_web.site.ContentBody,p_web.site.contentbodydivclass)
      End
      p_web.DivHeader('UpdateAccident',p_web.combine(p_web.site.style.formdiv,))
      p_web.DivHeader('UpdateAccident_alert',p_web.combine(p_web.site.MessageClass,' nt-hidden'))
      p_web.DivFooter()
    End
    do SetPics
    if loc:FrontLoading = net:GeneratingData
      do GenerateData
    else
      do GenerateForm
      p_web.DivFooter()
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdateAccident')
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
    loc:poppedup = p_web.GetValue('_UpdateAccident:_poppedup_')
    if p_web.site.FrontLoaded then loc:popup = 1.
    if loc:poppedup = 0 and p_Web.Ajax = 0
      If p_web.GetPreCall('UpdateAccident') = 0 and (p_web.GetValue('_CallPopups') = 0 or p_web.GetValue('_CallPopups') = 1)
        p_web.AddPreCall('UpdateAccident')
        p_web.DivHeader('popup_UpdateAccident','nt-hidden',,,,1,,,'popup_UpdateAccident')
        p_web.DivHeader('UpdateAccident',p_web.combine(p_web.site.style.formdiv,),,,,1)
        If p_web.site.FrontLoaded
          loc:frontloading = net:GeneratingPage
          do GenerateForm
        End
        p_web.DivFooter()
        p_web.DivFooter(,lower('popup_UpdateAccident End'))
        do Heading
        loc:options.Free(True)
        p_web.SetOption(loc:options,'close','function(event, ui) {{ ntd.pop(); }')
        p_web.SetOption(loc:options,'autoOpen','false')
        p_web.SetOption(loc:options,'width',900)
        p_web.SetOption(loc:options,'modal','true')
        p_web.SetOption(loc:options,'title',loc:Heading)
        p_web.SetOption(loc:options,'position','{{ my: "top", at: "top+' & clip(15) & '", of: window }')
        If p_web.CanCallAddSec() = net:ok
          p_web.SetOption(loc:options,'addsec','UpdateAccident')
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
        p_web.jQuery('#' & lower('popup_UpdateAccident_div'),'dialog',loc:options,'.removeClass("nt-hidden")')
      End
      do popups ! includes all the other popups dependant on this procedure
      loc:poppedup = 1
      p_web.SetValue('_UpdateAccident:_poppedup_',1)
    end

  of Net:Web:AfterLookup + Net:Web:Cancel
    loc:LookupDone = 0
    do AfterLookup
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdateAccident')&'_div'').dialog(''close'');')
    end

  of Net:Web:AfterLookup
    loc:LookupDone = 1
    do AfterLookup

  of Net:Web:Cancel
    do CancelForm
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdateAccident')&'_div'').dialog(''close'');')
    end

  of Net:InsertRecord + NET:WEB:StagePre
    if p_web._InsertAfterSave = 0
      p_web.setsessionvalue('SaveReferUpdateAccident',p_web.getPageName(p_web.RequestReferer))
    end
    do PreInsert
  of Net:InsertRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateInsert
  of Net:InsertRecord + NET:WEB:StagePost
    do RestoreMem
    do PostWrite
    do PostInsert
  of Net:InsertRecord + NET:WEB:Populate
    do OpenFiles
    do InitForm
    do PreInsert
  of Net:CopyRecord + NET:WEB:StagePre
    p_web.setsessionvalue('SaveReferUpdateAccident',p_web.getPageName(p_web.RequestReferer))
    do PreCopy
  of Net:CopyRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateCopy
  of Net:CopyRecord + NET:WEB:StagePost
    do RestoreMem
    do PostWrite
    do PostCopy
  of Net:CopyRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Acc:Guid') = 0 then p_web.SetValue('Acc:Guid',p_web.GetSessionValue('Acc:Guid')).
    do PreCopy
  of Net:ChangeRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdateAccident',p_web.getPageName(p_web.RequestReferer))      !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateAccident',0)           !
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
    If false
    ElsIf loc:act = Net:InsertRecord
      do PostWrite
      do PostInsert
    ElsIf loc:act = Net:CopyRecord
      do ValidateCopy
    Else
      do PostWrite
      do PostUpdate
    End
  of Net:ChangeRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Acc:Guid') = 0 then p_web.SetValue('Acc:Guid',p_web.GetSessionValue('Acc:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateAccident',0)     !
  of Net:DeleteRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdateAccident',p_web.getPageName(p_web.RequestReferer))   !
    do PreDelete
  of Net:DeleteRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateDelete
  of Net:DeleteRecord + NET:WEB:StagePost
    do RestoreMem
    do PostDelete
  of Net:ViewRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Acc:Guid') = 0 then p_web.SetValue('Acc:Guid',p_web.GetSessionValue('Acc:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateAccident',0)  !

  of Net:ViewRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdateAccident',p_web.getPageName(p_web.RequestReferer))   !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateAccident',0)    !
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
    p_web.SetSessionValue('showtab_UpdateAccident',Loc:InvalidTab)   !
  ElsIf band(p_stage,NET:WEB:StageValidate) > 0 and band(p_stage,Net:DeleteRecord) <> Net:DeleteRecord and band(p_stage,Net:WriteMask) > 0 and p_web.Ajax = 1 and loc:popup
    If p_web.IfExistsValue('_stayopen_')
    ! only a partial save, so don't complete the form.
    ElsIf loc:FormOnSave = Net:InsertAgain
      If band(loc:act,Net:InsertRecord) <> Net:InsertRecord
        p_web.script('$(''#popup_'&lower('UpdateAccident')&'_div'').dialog(''close'');')
      End
    Else
      p_web.script('$(''#popup_'&lower('UpdateAccident')&'_div'').dialog(''close'');')
    End
  End
  If loc:alert <> ''             !
    p_web.SetAlert(loc:alert, net:Alert + Net:Message,'UpdateAccident',1)
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
    p_web.AlertParent('UpdateAccident')
  Elsif p_web.formsettings.parentpage
    parentrid_ = p_web.GetValue('_parentrid_')
    p_web.SetValue('_parentrid_','')
    p_web.SetValue('_ParentProc_',p_web.formsettings.parentpage)
    p_web.AlertParent('UpdateAccident')
    p_web.SetValue('_ParentProc_','')
    p_web.SetValue('_parentrid_',parentrid_)
  Else
    p_web.AlertParent('UpdateAccident')
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
  p_web.SetValue('UpdateAccident_form:inited_',1)
  p_web.formsettings.file = 'Accident'
  p_web.formsettings.key = 'Acc:GuidKey'
  do RestoreMem

SetFormSettings  routine
  data
  code
  If p_web.Formstate = ''
    p_web.formsettings.file = 'Accident'
    p_web.formsettings.key = 'Acc:GuidKey'
      clear(p_web.formsettings.FieldName)
    p_web.formsettings.recordid[1] = Acc:Guid
    p_web.formsettings.FieldName[1] = 'Acc:Guid'
    do SetAction
    if p_web.GetSessionValue('UpdateAccident:Primed') = 1 or Ans = Net:ChangeRecord
      p_web.formsettings.action = Net:ChangeRecord
    Else
      p_web.formsettings.action = Loc:Act
    End
    p_web.formsettings.OriginalAction = Loc:Act
    If p_web.GetValue('_parentPage') <> ''
      p_web.formsettings.parentpage = p_web.GetValue('_parentPage')
    else
      p_web.formsettings.parentpage = 'UpdateAccident'
    end
    p_web.formsettings.proc = 'UpdateAccident'
    clear(p_web.formsettings.target)
    p_web.FormState = p_web.AddSettings()
  end

CancelForm  Routine
  IF p_web.GetSessionValue('UpdateAccident:Primed') = 1
    p_web.DeleteFile(Accident)
    p_web.SetSessionValue('UpdateAccident:Primed',0)
  End
  p_web.SetSessionValue('UpdateAccident:Active',0)

SendMessage Routine
  p_web.Message('Alert',loc:alert,p_web.site.MessageClass,Net:Send,1)

SetPics  Routine
  p_web.SetValue('UpdateFile','Accident')
  p_web.SetValue('UpdateKey','Acc:GuidKey')
  If p_web.IfExistsValue('Acc:Description')
    p_web.SetPicture('Acc:Description','@s255')
  End
  p_web.SetSessionPicture('Acc:Description','@s255')
  If p_web.IfExistsValue('Acc:Latitude')
    p_web.SetPicture('Acc:Latitude','@N-20.12')
  End
  p_web.SetSessionPicture('Acc:Latitude','@N-20.12')
  If p_web.IfExistsValue('Acc:Longitude')
    p_web.SetPicture('Acc:Longitude','@N-20.12')
  End
  p_web.SetSessionPicture('Acc:Longitude','@N-20.12')
  If p_web.IfExistsValue('Acc:Time')
    p_web.SetPicture('Acc:Time','@t1')
  End
  p_web.SetSessionPicture('Acc:Time','@t1')
  If p_web.IfExistsValue('Acc:markerOpacity')
    p_web.SetPicture('Acc:markerOpacity','@n-14')
  End
  p_web.SetSessionPicture('Acc:markerOpacity','@n-14')
  If p_web.IfExistsValue('Acc:Date')
    p_web.SetPicture('Acc:Date',p_web.site.DatePicture)
  End
  p_web.SetSessionPicture('Acc:Date',p_web.site.DatePicture)

AfterLookup Routine
  loc:TabNumber = -1
  If  true
    loc:TabNumber += 1
  End ! Tab Condition
  p_web.DeleteValue('LookupField')

StoreMem  Routine

! RestoreMem primes all the non-file fields with their session value. Useful in Validate and PostAction routines
RestoreMem  Routine
  !FormSource=File

SetAction  routine
  data
  code
  If Band(p_Stage,Net:ViewRecord) = Net:ViewRecord
    Loc:ViewOnly = true
    loc:action = p_web.site.ViewPromptText
    loc:act = Net:ViewRecord
    p_web.SetValue('_viewonly_',1) ! cascade ViewOnly mode to child procedures
    p_web.SetSessionValue('UpdateAccident_CurrentAction',Net:ViewRecord)
  Else
    Case p_web.GetSessionValue('UpdateAccident_CurrentAction')
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
    loc:formaction = p_web.getsessionvalue('SaveReferUpdateAccident')
  End
  if p_web.GetValue('_ChainToPage_') <> ''
    loc:formaction = p_web.GetValue('_ChainToPage_')
    p_web.SetSessionValue('UpdateAccident_ChainTo',loc:FormAction)
    loc:formactiontarget = '_self'
  ElsIf p_web.IfExistsSessionValue('UpdateAccident_ChainTo')
    loc:formaction = p_web.GetSessionValue('UpdateAccident_ChainTo')
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
  do Refresh::Acc:Description
  do Refresh::Acc:Latitude
  do Refresh::Acc:Longitude
  do Refresh::Acc:Date
  do Refresh::Acc:Time
  do Refresh::Acc:Type
  do Refresh::Acc:markerObject
  do Refresh::Acc:markerOpacity
  p_web.Script('$(''#'&clip(loc:formname)&''').find(''#FormState'').val('''&clip(p_web.FormState)&''');' & p_web.CRLF)
  p_web.ntForm(loc:formname,'show')

PopulateData  Routine

GenerateForm  Routine
  data
loc:disabled  Long
loc:pos       Long
  code
  p_web.ClearBrowse('UpdateAccident')
  do LoadRelatedRecords
  do SetFormAction
  do ntForm
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
      packet.append('<div id="'&  lower('Tab_UpdateAccident') & '_div" class="' & p_web.combine(p_web.site.style.FormTabOuter,,' nt-tab-carousel') & '">')
    of Net:Web:TaskPanel
    of Net:Web:Wizard
      packet.append(p_web.DivHeader('Tab_UpdateAccident',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    Else
      packet.append(p_web.DivHeader('Tab_UpdateAccident',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    End
    Case loc:TabStyle
    of Net:Web:Tab
      packet.append('<ul class="'&p_web.combine(p_web.site.style.FormTabTitle,)&'">'& p_web.CRLF)
      If  true
        packet.append('<li><a href="#' & lower('tab_UpdateAccident0_div') & '">' & '<div>' & p_web.Translate('General',true)&'</div></a></li>'& p_web.CRLF) !a
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
          packet.append('<div id="UpdateAccident_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdateAccident_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdateAccident')) !f1
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdateAccident')) !f2
        End
        loc:javascript = ''
        packet.append(p_web.CreateStdButton('button',Net:Web:SaveButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdateAccident',1)) !f3
        loc:javascript = ''
        if p_web.formsettings.action <> Net:InsertRecord
          packet.append(p_web.CreateStdButton('button',Net:Web:DeletefButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdateAccident')) !f4
        end
        loc:javascript = ''
        if loc:popup
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdateAccident')) !f5
        else
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdateAccident')) !f6
        end
        packet.append('</div>'  & p_web.CRLF) ! end id="UpdateAccident_saveset"
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdateAccident_saveset','controlgroup',loc:options)
        End
      ElsIf loc:ViewOnly = 1 and (loc:AutoSave=0 or loc:Act <> Net:ChangeRecord)
        If loc:TabStyle = Net:Web:Wizard
          packet.append('<div id="UpdateAccident_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdateAccident_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdateAccident')) !f8
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdateAccident')) !f9
        End
        loc:javascript = ''
        if loc:popup
          loc:javascript = clip(loc:javascript) & 'ntd.close();'
          packet.append(p_web.CreateStdButton('button',Net:Web:CloseButton,loc:formname,,,loc:javascript,,,,'UpdateAccident')) !f10
        else
          packet.append(p_web.CreateStdButton('submit',Net:Web:CloseButton,loc:formname,loc:formactioncancel,loc:formactioncanceltarget,,,,,'UpdateAccident')) !f11
        end
        packet.append('</div>' & p_web.CRLF)
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdateAccident_saveset','controlgroup',loc:options)
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
      p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdateAccident')>0,p_web.GetSessionValue('showtab_UpdateAccident'),'0'))
      p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdateAccident_tabchanged'',$(this).accordion("option","active")); }')
      p_web.jQuery('#' & lower('Tab_UpdateAccident') & '_div','accordion',loc:options)
    of Net:Web:TaskPanel
    of Net:Web:Tab
      p_web.SetOption(loc:options,'activate','function(event,ui){{TabChanged(''UpdateAccident_tabchanged'',$(this).tabs("option","active"));}')
      p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdateAccident')>0,p_web.GetSessionValue('showtab_UpdateAccident'),'0'))
      p_web.jQuery('#' & lower('Tab_UpdateAccident') & '_div','tabs',loc:options)
    of Net:Web:Wizard
       p_web.SetOption(loc:options,'procedure',lower('UpdateAccident'))
       p_web.SetOption(loc:options,'popup',loc:popup)
  
       p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdateAccident')>0,p_web.GetSessionValue('showtab_UpdateAccident'),0))
       p_web.SetOption(loc:options,'ntform', '#' & clip(loc:formname))
       p_web.ntWiz('UpdateAccident',loc:options)
    of Net:Web:Carousel
       p_web.SetOption(loc:options,'id',lower('tab_UpdateAccident_div'))
       p_web.SetOption(loc:options,'dots','^true')
       p_web.SetOption(loc:options,'autoplay','^false')
       p_web.jQuery('#' & lower('tab_UpdateAccident_div'),'slick',loc:options)
    end
    do SendPacket
  packet.append('</form>'&p_web.CRLF)
  do SendPacket
  loc:options.Free(True)
  If p_web.CanCallAddSec() = net:ok
    p_web.SetOption(loc:options,'addsec','UpdateAccident')
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
    p_web.AddPreCall('UpdateAccident')
    p_web.SetValue('_popup_',0)
    p_web.PopEvent()
  End

ntForm Routine
  data
loc:BuildOptions                stringTheory
  code
  p_web.SetOption(loc:options,'id',clip(loc:formname))
  p_web.SetOption(loc:options,'procedure', lower('UpdateAccident'))
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
        '<div>' & p_web.Translate('General')&'</div>' &|
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdateAccident0',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_UpdateAccident0_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate('General')&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdateAccident0',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_UpdateAccident0',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_UpdateAccident0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="0"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_UpdateAccident0_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-tab-carousel-header',)&'">'&|
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_UpdateAccident0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-rounded-header ui-corner-all',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_UpdateAccident0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend,,,1) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset"><legend class="'&p_web.combine(' nt-plain-legend',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</legend>' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_UpdateAccident0',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('UpdateAccident_container',p_web.combine(,),,loc:LayoutMethod))
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:Description_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:Description-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Acc:Description
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
        do Value::Acc:Description
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:Description
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:Latitude_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:Latitude-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Acc:Latitude
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
        do Value::Acc:Latitude
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:Latitude
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:Longitude_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:Longitude-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Acc:Longitude
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
        do Value::Acc:Longitude
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:Longitude
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:Date_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:Date-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Acc:Date
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
        do Value::Acc:Date
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:Date
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:Time_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:Time-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Acc:Time
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
        do Value::Acc:Time
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:Time
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:Type_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:Type-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(' nt-prompt-align-top',), ,  ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypePrompt))
          loc:columncounter += 1
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Prompt::Acc:Type
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
        do Value::Acc:Type
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:Type
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:markerObject_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:markerObject-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Acc:markerObject
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
        do Value::Acc:markerObject
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:markerObject
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Acc:markerOpacity_row')) ,p_web.Combine(lower(' UpdateAccident-Acc:markerOpacity-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Acc:markerOpacity
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
        do Value::Acc:markerOpacity
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Acc:markerOpacity
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
        packet.append(p_web.FormTableEnd('UpdateAccident_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('UpdateAccident_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('UpdateAccident_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_UpdateAccident0'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdateAccident')>0,p_web.GetSessionValue('showtab_UpdateAccident'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdateAccident_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_UpdateAccident0_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdateAccident0'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdateAccident0'))
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
    loc:Heading = p_web.Translate('Update Accident',(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
  End
  If p_web.site.HeaderBackButton and (loc:inNetWebPopup or loc:popup)
    loc:Heading = p_web.AddHeaderBackButton(loc:Heading,,)
  End
  If loc:inNetWebPopup = 1
    exit
  end
  If loc:Heading
    If loc:popup
      p_web.SetPopupDialogHeading('UpdateAccident',clip(loc:Heading),(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
    Else
      packet.append(lower('<div id="form-access-UpdateAccident"></div>'))
        p_web.DivHeader('UpdateAccident_header',p_web.combine(p_web.site.style.formheading,))
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

Refresh::Acc:Description  Routine
  do Prompt::Acc:Description
  do Value::Acc:Description
  do Comment::Acc:Description

Prompt::Acc:Description  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Description') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Description:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:Description')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:Description')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:Description Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:Description = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s255
    Acc:Description = p_web.DeformatValue(p_web.GetValue('Value'),'@s255')
  End
  do ValidateValue::Acc:Description  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:Description   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:Description  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Acc:Description',Acc:Description).

Value::Acc:Description  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:Description') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Description') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Acc:Description = p_web.RestoreValue('Acc:Description')
    do ValidateValue::Acc:Description
    If Acc:Description:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Acc:Description
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Acc:Description')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Acc:Description'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Acc:Description',p_web.GetSessionValueFormat('Acc:Description'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s255'),,'Acc:Description',,'imm',,,,'UpdateAccident')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:Description  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:Description:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Description') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:Description') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Acc:Latitude  Routine
  do Prompt::Acc:Latitude
  do Value::Acc:Latitude
  do Comment::Acc:Latitude

Prompt::Acc:Latitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Latitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Latitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:Latitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:Latitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:Latitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:Latitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @N-20.12
    Acc:Latitude = p_web.DeformatValue(p_web.GetValue('Value'),'@N-20.12')
  End
  do ValidateValue::Acc:Latitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:Latitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:Latitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Acc:Latitude',Acc:Latitude).

Value::Acc:Latitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:Latitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Latitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Acc:Latitude = p_web.RestoreValue('Acc:Latitude')
    do ValidateValue::Acc:Latitude
    If Acc:Latitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Acc:Latitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Acc:Latitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Acc:Latitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Acc:Latitude',p_web.GetSessionValueFormat('Acc:Latitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@N-20.12'),,'Acc:Latitude',,'imm',,,,'UpdateAccident')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:Latitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:Latitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Latitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:Latitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Acc:Longitude  Routine
  do Prompt::Acc:Longitude
  do Value::Acc:Longitude
  do Comment::Acc:Longitude

Prompt::Acc:Longitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Longitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Longitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:Longitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:Longitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:Longitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:Longitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @N-20.12
    Acc:Longitude = p_web.DeformatValue(p_web.GetValue('Value'),'@N-20.12')
  End
  do ValidateValue::Acc:Longitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:Longitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:Longitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Acc:Longitude',Acc:Longitude).

Value::Acc:Longitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:Longitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Longitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Acc:Longitude = p_web.RestoreValue('Acc:Longitude')
    do ValidateValue::Acc:Longitude
    If Acc:Longitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Acc:Longitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Acc:Longitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Acc:Longitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Acc:Longitude',p_web.GetSessionValueFormat('Acc:Longitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@N-20.12'),,'Acc:Longitude',,'imm',,,,'UpdateAccident')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:Longitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:Longitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Longitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:Longitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Acc:Date  Routine
  do Prompt::Acc:Date
  do Value::Acc:Date
  do Comment::Acc:Date

Prompt::Acc:Date  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Date') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Date:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:Date')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:Date')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:Date Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:Date = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value')
    Acc:Date = p_web.DeformatValue(clip(p_web.GetValue('Value')),p_web.site.DatePicture)
  End
  do ValidateValue::Acc:Date  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:Date   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:Date  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Acc:Date',Acc:Date).

Value::Acc:Date  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:Date') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Date') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Date
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Acc:Date = p_web.RestoreValue('Acc:Date')
    do ValidateValue::Acc:Date
    If Acc:Date:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- DATE --- Acc:Date
    loc:AutoComplete = 'autocomplete="off"'
    loc:javascript = ''  ! MakeFormJavaScript
    loc:readonly = Choose(loc:viewonly,'1','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Acc:Date')&''').datepicker(''setDate'','''&p_web._jsok(left(p_web.GetSessionValueFormat('Acc:Date')))&''');')
    Else
      loc:options.Free(True)
      loc:options.SetValue(p_web.site.Dateoptions,st:clip)
      p_web.SplitOptions(loc:options)
      ! example of using loc:options;
      !   p_web.SetOption(loc:options,'numberOfMonths',3) ! see http://jqueryui.com/demos/datepicker/#options
      packet.append(p_web.CreateDateInput ('Acc:Date',p_web.GetSessionValueFormat('Acc:Date'),loc:fieldclass,loc:readonly,,,loc:javascript,loc:options,loc:extra,,,,,,0,,'imm',,,'UpdateAccident',0))
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:Date  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:Date:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
    loc:comment = p_web.InterpretPicture()
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Date') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:Date') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Acc:Time  Routine
  do Prompt::Acc:Time
  do Value::Acc:Time
  do Comment::Acc:Time

Prompt::Acc:Time  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Time') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Time:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:Time')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:Time')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:Time Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:Time = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture = '@t1'  !FieldPicture = @n-14
    Acc:Time = p_web.DeformatValue(p_web.GetValue('Value'),'@t1')
  End
  do ValidateValue::Acc:Time  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:Time   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:Time  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Acc:Time',Acc:Time).

Value::Acc:Time  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:Time') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Time') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Acc:Time = p_web.RestoreValue('Acc:Time')
    do ValidateValue::Acc:Time
    If Acc:Time:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Acc:Time
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Acc:Time')&''').val('''&p_web._jsok(p_web.FormatValue(p_web.GetSessionValue('Acc:Time'),'@t1'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Acc:Time',p_web.GetSessionValue('Acc:Time'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),'@t1',loc:javascript,,,'Acc:Time',,'imm',,,,'UpdateAccident')  & p_web.CRLF) !a
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:Time  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:Time:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Time') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:Time') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Acc:Type  Routine
  do Prompt::Acc:Type
  do Value::Acc:Type
  do Comment::Acc:Type

Prompt::Acc:Type  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Type') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Type:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:Type')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:Type')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:Type Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:Type = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @n-14
    Acc:Type = p_web.DeformatValue(p_web.GetValue('Value'),'@n-14')
  End
  do ValidateValue::Acc:Type  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:Type   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:Type  Routine
            Case Acc:Type
            Of 1
            Of 2
            Of 3
            Of 4
            Of 5
            Else
              loc:Invalid = 'Acc:Type'
              Acc:Type:IsInvalid = true
              If Not loc:alert then loc:alert = 'Acc:Type ' & p_web.translate('Invalid').
            End
          If loc:invalid = '' then p_web.SetSessionValue('Acc:Type',Acc:Type).

Value::Acc:Type  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:Type') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Type') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formradio,,)
  If loc:retrying
    Acc:Type = p_web.RestoreValue('Acc:Type')
    do ValidateValue::Acc:Type
    If Acc:Type:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- RADIO --- Acc:Type
    If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
         If p_web.GetSessionValue('Acc:Type') = 1
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_1')&''').attr(''checked'',''checked'');')
         Else
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_1')&''').removeAttr(''checked'');')
         End
         If p_web.GetSessionValue('Acc:Type') = 2
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_2')&''').attr(''checked'',''checked'');')
         Else
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_2')&''').removeAttr(''checked'');')
         End
         If p_web.GetSessionValue('Acc:Type') = 3
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_3')&''').attr(''checked'',''checked'');')
         Else
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_3')&''').removeAttr(''checked'');')
         End
         If p_web.GetSessionValue('Acc:Type') = 4
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_4')&''').attr(''checked'',''checked'');')
         Else
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_4')&''').removeAttr(''checked'');')
         End
         If p_web.GetSessionValue('Acc:Type') = 5
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_5')&''').attr(''checked'',''checked'');')
         Else
           p_web.Script('$(''#'&p_web.nocolon('Acc:Type_5')&''').removeAttr(''checked'');')
         End
      p_web.Script('$(''#'& lower('UpdateAccident') & '_' & p_web.nocolon('Acc:Type_value_div')&''').checkboxradio("refresh");')
    Else
      loc:javascript = ''  ! MakeFormJavaScript
      packet.append('<div class="nt-radio-div-buttons-hor">')
        loc:readonly = Choose(loc:viewonly,'disabled','')
        loc:readonly = clip(loc:readonly) & Choose(p_web.GetSessionValue('Acc:Type') = 1,' checked','')
        packet.append(p_web.CreateRadio('Acc:Type','Acc:Type_1',clip(1),'Car',1 ,1 ,loc:fieldclass,loc:readonly,loc:extra,loc:javascript,,,'imm','UpdateAccident',,'','','',''))
        loc:options.Free(True)
        p_web.jQuery('#Acc:Type_1','checkboxradio',loc:options)
        loc:readonly = Choose(loc:viewonly,'disabled','')
        loc:readonly = clip(loc:readonly) & Choose(p_web.GetSessionValue('Acc:Type') = 2,' checked','')
        packet.append(p_web.CreateRadio('Acc:Type','Acc:Type_2',clip(2),'Bike',1 ,1 ,loc:fieldclass,loc:readonly,loc:extra,loc:javascript,,,'imm','UpdateAccident',,'','','',''))
        loc:options.Free(True)
        p_web.jQuery('#Acc:Type_2','checkboxradio',loc:options)
        loc:readonly = Choose(loc:viewonly,'disabled','')
        loc:readonly = clip(loc:readonly) & Choose(p_web.GetSessionValue('Acc:Type') = 3,' checked','')
        packet.append(p_web.CreateRadio('Acc:Type','Acc:Type_3',clip(3),'Bus',1 ,1 ,loc:fieldclass,loc:readonly,loc:extra,loc:javascript,,,'imm','UpdateAccident',,'','','',''))
        loc:options.Free(True)
        p_web.jQuery('#Acc:Type_3','checkboxradio',loc:options)
        loc:readonly = Choose(loc:viewonly,'disabled','')
        loc:readonly = clip(loc:readonly) & Choose(p_web.GetSessionValue('Acc:Type') = 4,' checked','')
        packet.append(p_web.CreateRadio('Acc:Type','Acc:Type_4',clip(4),'Truck',1 ,1 ,loc:fieldclass,loc:readonly,loc:extra,loc:javascript,,,'imm','UpdateAccident',,'','','',''))
        loc:options.Free(True)
        p_web.jQuery('#Acc:Type_4','checkboxradio',loc:options)
        loc:readonly = Choose(loc:viewonly,'disabled','')
        loc:readonly = clip(loc:readonly) & Choose(p_web.GetSessionValue('Acc:Type') = 5,' checked','')
        packet.append(p_web.CreateRadio('Acc:Type','Acc:Type_5',clip(5),'Pedestrian',1 ,1 ,loc:fieldclass,loc:readonly,loc:extra,loc:javascript,,,'imm','UpdateAccident',,'','','',''))
        loc:options.Free(True)
        p_web.jQuery('#Acc:Type_5','checkboxradio',loc:options)
      packet.append('</div>')
        loc:options.Free(True)
        p_web.jQuery(lower('#UpdateAccident_Acc:Type_value_div'),'controlgroup',loc:options)
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:Type  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:Type:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:Type') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:Type') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Acc:markerObject  Routine
  do Prompt::Acc:markerObject
  do Value::Acc:markerObject
  do Comment::Acc:markerObject

Prompt::Acc:markerObject  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:markerObject') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Marker:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:markerObject')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:markerObject')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:markerObject Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:markerObject = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s30
    Acc:markerObject = p_web.DeformatValue(p_web.GetValue('Value'),'@s30')
  End
  do ValidateValue::Acc:markerObject  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:markerObject   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:markerObject  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Acc:markerObject',Acc:markerObject).

Value::Acc:markerObject  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
loc:FirstDropValue  String(252)
loc:DropValueOk  Long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:markerObject') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:markerObject') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,p_web.site.style.formselect,,)
  If loc:retrying
    Acc:markerObject = p_web.RestoreValue('Acc:markerObject')
    do ValidateValue::Acc:markerObject
    If Acc:markerObject:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- DROPLIST ---
    loc:FirstDropValue = '---111222333NOTSET==='
    loc:DropValueOk = false
  
    loc:even = 1
    loc:javascript = ''  ! MakeFormJavaScript
    loc:readonly = Choose(loc:viewonly,'disabled','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
      packet.append(p_web.CreateSelect('Acc:markerObject',loc:fieldclass,loc:readonly,'','',0,loc:javascript,,,'Acc:markerObject','imm','UpdateAccident','selectmenu'))
    else
      p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').empty();')
    end
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = ''.
      If p_web.GetSessionValue('Acc:markerObject') = '' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('')&'">'& p_web.translate('Default')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Default','',choose(lower('') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'greenMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'greenMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('greenMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('greenMarker')&'">'& p_web.translate('Green')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Green','greenMarker',choose(lower('greenMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'brownMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'brownMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('brownMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('brownMarker')&'">'& p_web.translate('Brown')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Brown','brownMarker',choose(lower('brownMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'purpleMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'purpleMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('purpleMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('purpleMarker')&'">'& p_web.translate('Purple')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Purple','purpleMarker',choose(lower('purpleMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'redMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'redMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('redMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('redMarker')&'">'& p_web.translate('Red')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Red','redMarker',choose(lower('redMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'pinkMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'pinkMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('pinkMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('pinkMarker')&'">'& p_web.translate('Pink')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Pink','pinkMarker',choose(lower('pinkMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'blueMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'blueMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('blueMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('blueMarker')&'">'& p_web.translate('Blue')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Blue','blueMarker',choose(lower('blueMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'aquaMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'aquaMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('aquaMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('aquaMarker')&'">'& p_web.translate('Aqua')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Aqua','aquaMarker',choose(lower('aquaMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
      If loc:FirstDropValue = '---111222333NOTSET===' then loc:FirstDropValue = 'yellowMarker'.
      If p_web.GetSessionValue('Acc:markerObject') = 'yellowMarker' then loc:DropValueOk = true.
      If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
        p_web.Script('$(''#'&p_web.nocolon('Acc:markerObject')&''').append(''<option '& choose('yellowMarker' = p_web.getSessionValue('Acc:markerObject'),'selected="selected"','')&' value="'&p_web._jsok('yellowMarker')&'">'& p_web.translate('Yellow')&'</option>'');')
      Else
        packet.append(p_web.CreateOption('Yellow','yellowMarker',choose(lower('yellowMarker') = lower(p_web.getSessionValue('Acc:markerObject'))),'',loc:extra,)&p_web.CRLF) !k
      End
    loc:even = Choose(loc:even=1,2,1)
    if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
      packet.append('</select>'&p_web.CRLF)
    end
    loc:options.Free(True)
    p_web.SetOption(loc:options,'change','function(event,ui){{$(this).change();}')
    p_web.SetOption(loc:options, 'classes','{{"ui-menu":"nt-select-droplist","ui-selectmenu-button":"'&clip(loc:fieldclass)&'"}')
    p_web.jQuery('#Acc:markerObject','selectmenu',loc:options)
    p_web.jQuery('#Acc:markerObject','selectmenu','"menuWidget"','.addClass("' & p_web.combine('nt-select-height',) & '")')
    If loc:DropValueOk = false  and loc:FirstDropValue <> '---111222333NOTSET==='
      p_web.Script('$("#' & p_web.NoColon('Acc:markerObject') & '").val("'& p_web._jsok(loc:FirstDropValue) &'");$("#' & p_web.NoColon('Acc:markerObject') & '").selectmenu("refresh");')
      p_web.SetSessionValue('Acc:markerObject',loc:FirstDropValue)
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:markerObject  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:markerObject:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:markerObject') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:markerObject') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Acc:markerOpacity  Routine
  do Prompt::Acc:markerOpacity
  do Value::Acc:markerOpacity
  do Comment::Acc:markerOpacity

Prompt::Acc:markerOpacity  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:markerOpacity') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Marker Opacity:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Acc:markerOpacity')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Acc:markerOpacity')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Acc:markerOpacity Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Acc:markerOpacity = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @n-14
    Acc:markerOpacity = p_web.DeformatValue(p_web.GetValue('Value'),'@n-14')
  End
  do ValidateValue::Acc:markerOpacity  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Acc:markerOpacity   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Acc:markerOpacity  Routine
          If Numeric(Acc:markerOpacity) = 0
            loc:Invalid = 'Acc:markerOpacity'
            Acc:markerOpacity:IsInvalid = true
            if not loc:alert then loc:alert = p_web.translate('Marker Opacity:') & ' ' & p_web.site.NumericText.
          ElsIf InRange(Acc:markerOpacity,0,100) = false
            loc:Invalid = 'Acc:markerOpacity'
            Acc:markerOpacity:IsInvalid = true
            if not loc:alert then loc:alert = p_web.translate('Marker Opacity:') & ' ' & clip(p_web.site.MoreThanText) & ' ' & 0 & ', ' & clip(p_web.site.LessThanText) & ' ' & 100.    !g
          End
          If loc:invalid = '' then p_web.SetSessionValue('Acc:markerOpacity',Acc:markerOpacity).

Value::Acc:markerOpacity  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Acc:markerOpacity') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:markerOpacity') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Acc:markerOpacity = p_web.RestoreValue('Acc:markerOpacity')
    do ValidateValue::Acc:markerOpacity
    If Acc:markerOpacity:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Acc:markerOpacity
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Acc:markerOpacity')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Acc:markerOpacity'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Acc:markerOpacity',p_web.GetSessionValueFormat('Acc:markerOpacity'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@n-14'),'in %','Acc:markerOpacity',,'imm',,,,'UpdateAccident')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Acc:markerOpacity  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Acc:markerOpacity:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:comment = p_web.Translate('in %')
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateAccident_' & p_web.nocolon('Acc:markerOpacity') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateAccident_' & p_web.nocolon('Acc:markerOpacity') & '_comment_div").html("'&clip(loc:comment)&'");')
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
  of lower('UpdateAccident_nexttab_' & 0)
    Acc:Description = p_web.GetSessionValue('Acc:Description')
    do ValidateValue::Acc:Description
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:Description
      do Comment::Acc:Description ! allows comment style to be updated.
    End
    Acc:Latitude = p_web.GetSessionValue('Acc:Latitude')
    do ValidateValue::Acc:Latitude
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:Latitude
      do Comment::Acc:Latitude ! allows comment style to be updated.
    End
    Acc:Longitude = p_web.GetSessionValue('Acc:Longitude')
    do ValidateValue::Acc:Longitude
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:Longitude
      do Comment::Acc:Longitude ! allows comment style to be updated.
    End
    Acc:Date = p_web.GetSessionValue('Acc:Date')
    do ValidateValue::Acc:Date
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:Date
      do Comment::Acc:Date ! allows comment style to be updated.
    End
    Acc:Time = p_web.GetSessionValue('Acc:Time')
    do ValidateValue::Acc:Time
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:Time
      do Comment::Acc:Time ! allows comment style to be updated.
    End
    Acc:Type = p_web.GetSessionValue('Acc:Type')
    do ValidateValue::Acc:Type
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:Type
      do Comment::Acc:Type ! allows comment style to be updated.
    End
    Acc:markerObject = p_web.GetSessionValue('Acc:markerObject')
    do ValidateValue::Acc:markerObject
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:markerObject
      do Comment::Acc:markerObject ! allows comment style to be updated.
    End
    Acc:markerOpacity = p_web.GetSessionValue('Acc:markerOpacity')
    do ValidateValue::Acc:markerOpacity
    If loc:Invalid
      loc:retrying = 1
      do Value::Acc:markerOpacity
      do Comment::Acc:markerOpacity ! allows comment style to be updated.
    End
    If loc:Invalid then exit.
  End
  p_web.ntWiz('UpdateAccident','next')

ChangeTab  routine
  p_web.ChangeTab(loc:TabStyle,'UpdateAccident',loc:TabTo)

TabChanged  routine
  data
TabNumber   Long   !! remember that tabs are numbered from 0
TabHeading  String(252),dim(1)
  code
  tabnumber = p_web.GetValue('_tab_')
  tabheading[1]  = p_web.Translate('General')
  p_web.SetSessionValue('showtab_UpdateAccident',tabnumber) !! remember that tabs are numbered from 0

CallDiv    routine
  data
  code
  p_web.Ajax = 1
  p_web.PageName = p_web._unEscape(p_web.PageName)
  case lower(p_web.PageName)
  of lower('UpdateAccident') & '_tabchanged'
     do TabChanged
  of lower('UpdateAccident_tab_' & 0)
    do GenerateTab0
  of lower('UpdateAccident_Acc:Description_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:Description
        do AlertParent
      of 'timer'
        do refresh::Acc:Description
        do AlertParent
      else
        do Value::Acc:Description
      end
  of lower('UpdateAccident_Acc:Latitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:Latitude
        do AlertParent
      of 'timer'
        do refresh::Acc:Latitude
        do AlertParent
      else
        do Value::Acc:Latitude
      end
  of lower('UpdateAccident_Acc:Longitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:Longitude
        do AlertParent
      of 'timer'
        do refresh::Acc:Longitude
        do AlertParent
      else
        do Value::Acc:Longitude
      end
  of lower('UpdateAccident_Acc:Date_value')
      case p_web.Event ! Date
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:Date
        do AlertParent
      of 'timer'
        do refresh::Acc:Date
        do AlertParent
      else
        do Value::Acc:Date
      end
  of lower('UpdateAccident_Acc:Time_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:Time
        do AlertParent
      of 'timer'
        do refresh::Acc:Time
        do AlertParent
      else
        do Value::Acc:Time
      end
  of lower('UpdateAccident_Acc:Type_value')
  orof lower('UpdateAccident_Acc:Type_value')
      case p_web.Event ! Radio
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:Type
        do AlertParent
      of 'timer'
        do refresh::Acc:Type
        do AlertParent
      else
        do Value::Acc:Type
      end
  of lower('UpdateAccident_Acc:markerObject_value')
      case p_web.Event ! Drop
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:markerObject
        do AlertParent
      of 'timer'
        do refresh::Acc:markerObject
        do AlertParent
      else
        do Value::Acc:markerObject
      end
  of lower('UpdateAccident_Acc:markerOpacity_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Acc:markerOpacity
        do AlertParent
      of 'timer'
        do refresh::Acc:markerOpacity
        do AlertParent
      else
        do Value::Acc:markerOpacity
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
  p_web.SetValue('UpdateAccident_form:ready_',1)
  p_web.SetSessionValue('UpdateAccident:Active',1)
  p_web.SetSessionValue('UpdateAccident_CurrentAction',Net:InsertRecord)
  p_web.SetSessionValue('showtab_UpdateAccident',0)   !
  Clear(Acc:record) ! Primes moved before auto-increment (PrimeRecord) call.
  Acc:Guid = glo:st.Random(16,st:Upper+st:Number)            ! taken from dictionary initial value
  p_web.SetSessionValue('Acc:Guid',Acc:Guid)
  Acc:Date = today()
  p_web.SetSessionValue('Acc:Date',Acc:Date)    ! taken from priming tab
  Acc:Time = clock()
  p_web.SetSessionValue('Acc:Time',Acc:Time)    ! taken from priming tab
  Acc:markerOpacity = 100
  p_web.SetSessionValue('Acc:markerOpacity',Acc:markerOpacity)    ! taken from priming tab
  Acc:Type = 1
  p_web.SetSessionValue('Acc:Type',Acc:Type)    ! taken from priming tab
  If p_web.GetValue('_lat_') <> ''
    Acc:Latitude = p_web.GetValue('_lat_')  ! taken from priming tab
  End
  If p_web.GetValue('_lng_') <> ''
    Acc:Longitude = p_web.GetValue('_lng_')  ! taken from priming tab
  End
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreCopy  Routine
  data
  code
  p_web.SetValue('UpdateAccident_form:ready_',1)
  p_web.SetSessionValue('UpdateAccident:Active',1)
  p_web.SetSessionValue('UpdateAccident_CurrentAction',Net:CopyRecord)
  p_web.SetSessionValue('showtab_UpdateAccident',0)  !
  p_web._PreCopyRecord(Accident,Acc:GuidKey)
  Acc:Guid = glo:st.Random(16,st:Upper+st:Number)
  p_web.SetSessionValue('Acc:Guid',Acc:Guid)
  ! here we need to copy the non-unique fields across
  Acc:Date = today()
  p_web.SetSessionValue('Acc:Date',Acc:Date)
  Acc:Time = clock()
  p_web.SetSessionValue('Acc:Time',Acc:Time)
  Acc:markerOpacity = 100
  p_web.SetSessionValue('Acc:markerOpacity',Acc:markerOpacity)
  Acc:Type = 1
  p_web.SetSessionValue('Acc:Type',Acc:Type)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
! this code runs After the record is loaded. To run code before, see InitForm Routine
PreUpdate  Routine
  data
loc:offset      Long
  code
  p_web.SetValue('UpdateAccident_form:ready_',1)
  p_web.SetSessionValue('UpdateAccident:Active',1)
  p_web.SetSessionValue('UpdateAccident_CurrentAction',Net:ChangeRecord)
  p_web.SetSessionValue('UpdateAccident:Primed',0)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreDelete       Routine
  data
  code
  p_web.SetValue('UpdateAccident_form:ready_',1)
  p_web.SetSessionValue('UpdateAccident_CurrentAction',Net:DeleteRecord)
  p_web.SetSessionValue('UpdateAccident:Primed',0)
  p_web.SetSessionValue('showtab_UpdateAccident',0)   !
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
LoadRelatedRecords  Routine
  loc:ok = 0
  loc:ok = 0
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
          If p_web.IfExistsValue('Acc:Description')
            Acc:Description = p_web.GetValue('Acc:Description')
          End
          If p_web.IfExistsValue('Acc:Latitude')
            Acc:Latitude = p_web.GetValue('Acc:Latitude')
          End
          If p_web.IfExistsValue('Acc:Longitude')
            Acc:Longitude = p_web.GetValue('Acc:Longitude')
          End
          If p_web.IfExistsValue('Acc:Date')
            Acc:Date = p_web.GetValue('Acc:Date')
          End
          If p_web.IfExistsValue('Acc:Time')
            Acc:Time = p_web.GetValue('Acc:Time')
          End
          If p_web.IfExistsValue('Acc:Type')
            Acc:Type = p_web.GetValue('Acc:Type')
          End
          If p_web.IfExistsValue('Acc:markerObject')
            Acc:markerObject = p_web.GetValue('Acc:markerObject')
          End
          If p_web.IfExistsValue('Acc:markerOpacity')
            Acc:markerOpacity = p_web.GetValue('Acc:markerOpacity')
          End
  End   !tab condition

! NET:WEB:StageVALIDATE
ValidateInsert  Routine
  do CompleteForm
  do ValidateRecord
  do CheckForDuplicate

ValidateCopy  Routine
  do CompleteForm
  do ValidateRecord
  do CheckForDuplicate

ValidateUpdate  Routine
  do CompleteForm
  do ValidateRecord
  do CheckForDuplicate
CheckForDuplicate  Routine
  Data
GotFileZero    long
  Code
  If loc:invalid <> '' then exit. ! no need to check, record is already invalid
  If ans = 0 then exit. ! no need to check, as no action happening
  If p_web.GetSessionValue('UpdateAccident:Primed') = 0 and Ans = Net:InsertRecord
    Get(Accident,0)
    GotFileZero = true
  End
  ! Check for duplicates
  If Duplicate(Acc:GuidKey) ! In SQL drivers this clears the Blob field, if Get(file,0) was done. TPS does not.
    loc:Invalid = 'Acc:Guid'
    if not loc:alert then loc:Alert = clip(p_web.site.DuplicateText) & ' GuidKey --> Acc:Guid = ' & clip(Acc:Guid).
  End
  If GotFileZero
  End

ValidateDelete  Routine
  p_web.DeleteSessionValue('UpdateAccident_ChainTo')
  ! Check for restricted child records

ValidateRecord  Routine
  p_web.DeleteSessionValue('UpdateAccident_ChainTo')

  ! Then add additional constraints set on the template
  loc:InvalidTab = -1
  ! tab = 1
    If  true
        loc:InvalidTab += 1
        do ValidateValue::Acc:Description
        If loc:Invalid then exit.
        do ValidateValue::Acc:Latitude
        If loc:Invalid then exit.
        do ValidateValue::Acc:Longitude
        If loc:Invalid then exit.
        do ValidateValue::Acc:Date
        If loc:Invalid then exit.
        do ValidateValue::Acc:Time
        If loc:Invalid then exit.
        do ValidateValue::Acc:Type
        If loc:Invalid then exit.
        do ValidateValue::Acc:markerObject
        If loc:Invalid then exit.
        do ValidateValue::Acc:markerOpacity
        If loc:Invalid then exit.
  End ! Tab Condition
  ! The following fields are not on the form, but need to be checked anyway.
! NET:WEB:StagePOST
PostWrite  Routine
  Data
  Code

PostInsert      Routine
  Data
  Code
  If loc:FormOnSave = Net:InsertAgain
    p_web.InsertAgain('UpdateAccident')
    Clear(Acc:Record)
  Else
    p_web.SetSessionValue('UpdateAccident:Active',0)
  End
PostCopy        Routine
  Data
  Code
  p_web.SetSessionValue('UpdateAccident:Primed',0)
  p_web.SetSessionValue('UpdateAccident:Active',0)

PostUpdate      Routine
  Data
  Code
  p_web.SetSessionValue('UpdateAccident:Primed',0)
  p_web.SetSessionValue('UpdateAccident:Active',0)

PostDelete      Routine
