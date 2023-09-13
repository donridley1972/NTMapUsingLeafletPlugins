

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76006.INC'),ONCE        !Local module procedure declarations
                     END


UpdatePatrolAreaBoundary PROCEDURE  (NetWebServerWorker p_web,long p_stage=0)
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
PatrolAreaBoundary::State  USHORT
PatrolArea::State  USHORT
Ptb:PatGuid:IsInvalid  Long
Ptb:Order:IsInvalid  Long
Ptb:Description:IsInvalid  Long
Ptb:Latitude:IsInvalid  Long
Ptb:Longitude:IsInvalid  Long
PointMap:IsInvalid  Long
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
Ptb:PatGuid_OptionView   View(PatrolArea)
                          Project(Pat:Guid)
                          Project(Pat:Name)
                        End
  CODE
  loc:procedure = lower('UpdatePatrolAreaBoundary')
  GlobalErrors.SetProcedureName('UpdatePatrolAreaBoundary')
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
  loc:formname = lower('UpdatePatrolAreaBoundary_frm')
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
      if p_web.Event = 'parentnewselection' or  p_web.GetValue('UpdatePatrolAreaBoundary:parentIs') = 'Browse' ! allow for form used as a child of a browse, default to change mode.
        p_web.FormReady('UpdatePatrolAreaBoundary','Change','Ptb:Guid',p_web.GetSessionValue('Ptb:Guid'))
      Else
        p_web.FormReady('UpdatePatrolAreaBoundary','')
      End
    End
    if p_web.site.frontloaded and p_web.Ajax and loc:popup = 1
      loc:FrontLoading = net:GeneratingData
    else
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdatePatrolAreaBoundary')
        p_web.DivHeader(p_web.site.ContentBody,p_web.site.contentbodydivclass)
      End
      p_web.DivHeader('UpdatePatrolAreaBoundary',p_web.combine(p_web.site.style.formdiv,))
      p_web.DivHeader('UpdatePatrolAreaBoundary_alert',p_web.combine(p_web.site.MessageClass,' nt-hidden'))
      p_web.DivFooter()
    End
    do SetPics
    if loc:FrontLoading = net:GeneratingData
      do GenerateData
    else
      do GenerateForm
      p_web.DivFooter()
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdatePatrolAreaBoundary')
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
    loc:poppedup = p_web.GetValue('_UpdatePatrolAreaBoundary:_poppedup_')
    if p_web.site.FrontLoaded then loc:popup = 1.
    if loc:poppedup = 0 and p_Web.Ajax = 0
      If p_web.GetPreCall('UpdatePatrolAreaBoundary') = 0 and (p_web.GetValue('_CallPopups') = 0 or p_web.GetValue('_CallPopups') = 1)
        p_web.AddPreCall('UpdatePatrolAreaBoundary')
        p_web.DivHeader('popup_UpdatePatrolAreaBoundary','nt-hidden',,,,1,,,'popup_UpdatePatrolAreaBoundary')
        p_web.DivHeader('UpdatePatrolAreaBoundary',p_web.combine(p_web.site.style.formdiv,),,,,1)
        If p_web.site.FrontLoaded
          loc:frontloading = net:GeneratingPage
          do GenerateForm
        End
        p_web.DivFooter()
        p_web.DivFooter(,lower('popup_UpdatePatrolAreaBoundary End'))
        do Heading
        loc:options.Free(True)
        p_web.SetOption(loc:options,'close','function(event, ui) {{ ntd.pop(); }')
        p_web.SetOption(loc:options,'autoOpen','false')
        p_web.SetOption(loc:options,'width',900)
        p_web.SetOption(loc:options,'modal','true')
        p_web.SetOption(loc:options,'title',loc:Heading)
        p_web.SetOption(loc:options,'position','{{ my: "top", at: "top+' & clip(15) & '", of: window }')
        If p_web.CanCallAddSec() = net:ok
          p_web.SetOption(loc:options,'addsec','UpdatePatrolAreaBoundary')
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
        p_web.jQuery('#' & lower('popup_UpdatePatrolAreaBoundary_div'),'dialog',loc:options,'.removeClass("nt-hidden")')
      End
      do popups ! includes all the other popups dependant on this procedure
      loc:poppedup = 1
      p_web.SetValue('_UpdatePatrolAreaBoundary:_poppedup_',1)
    end

  of Net:Web:AfterLookup + Net:Web:Cancel
    loc:LookupDone = 0
    do AfterLookup
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdatePatrolAreaBoundary')&'_div'').dialog(''close'');')
    end

  of Net:Web:AfterLookup
    loc:LookupDone = 1
    do AfterLookup

  of Net:Web:Cancel
    do CancelForm
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdatePatrolAreaBoundary')&'_div'').dialog(''close'');')
    end

  of Net:InsertRecord + NET:WEB:StagePre
    if p_web._InsertAfterSave = 0
      p_web.setsessionvalue('SaveReferUpdatePatrolAreaBoundary',p_web.getPageName(p_web.RequestReferer))
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
    p_web.setsessionvalue('SaveReferUpdatePatrolAreaBoundary',p_web.getPageName(p_web.RequestReferer))
    do PreCopy
  of Net:CopyRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateCopy
  of Net:CopyRecord + NET:WEB:StagePost
    do RestoreMem
    do PostWrite
    do PostCopy
  of Net:CopyRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Ptb:Guid') = 0 then p_web.SetValue('Ptb:Guid',p_web.GetSessionValue('Ptb:Guid')).
    do PreCopy
  of Net:ChangeRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdatePatrolAreaBoundary',p_web.getPageName(p_web.RequestReferer))      !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',0)           !
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
    If p_web.IfExistsValue('Ptb:Guid') = 0 then p_web.SetValue('Ptb:Guid',p_web.GetSessionValue('Ptb:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',0)     !
  of Net:DeleteRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdatePatrolAreaBoundary',p_web.getPageName(p_web.RequestReferer))   !
    do PreDelete
  of Net:DeleteRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateDelete
  of Net:DeleteRecord + NET:WEB:StagePost
    do RestoreMem
    do PostDelete
  of Net:ViewRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Ptb:Guid') = 0 then p_web.SetValue('Ptb:Guid',p_web.GetSessionValue('Ptb:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',0)  !

  of Net:ViewRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdatePatrolAreaBoundary',p_web.getPageName(p_web.RequestReferer))   !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',0)    !
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
    p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',Loc:InvalidTab)   !
  ElsIf band(p_stage,NET:WEB:StageValidate) > 0 and band(p_stage,Net:DeleteRecord) <> Net:DeleteRecord and band(p_stage,Net:WriteMask) > 0 and p_web.Ajax = 1 and loc:popup
    If p_web.IfExistsValue('_stayopen_')
    ! only a partial save, so don't complete the form.
    ElsIf loc:FormOnSave = Net:InsertAgain
      If band(loc:act,Net:InsertRecord) <> Net:InsertRecord
        p_web.script('$(''#popup_'&lower('UpdatePatrolAreaBoundary')&'_div'').dialog(''close'');')
      End
    Else
      p_web.script('$(''#popup_'&lower('UpdatePatrolAreaBoundary')&'_div'').dialog(''close'');')
    End
  End
  If loc:alert <> ''             !
    p_web.SetAlert(loc:alert, net:Alert + Net:Message,'UpdatePatrolAreaBoundary',1)
  End                            !
  do CloseFiles
  GlobalErrors.SetProcedureName()
  return Ans

OpenFiles  ROUTINE
  FilesErrorOnOpen.SetValue('')
  If p_web.OpenFile(PatrolAreaBoundary) <> 0
    FilesErrorOnOpen.Append('PatrolAreaBoundary',st:clip,',')
  End
  If p_web.OpenFile(PatrolArea) <> 0
    FilesErrorOnOpen.Append('PatrolArea',st:clip,',')
  End
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened
  p_Web.CloseFile(PatrolAreaBoundary)
  p_Web.CloseFile(PatrolArea)
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
    p_web.AlertParent('UpdatePatrolAreaBoundary')
  Elsif p_web.formsettings.parentpage
    parentrid_ = p_web.GetValue('_parentrid_')
    p_web.SetValue('_parentrid_','')
    p_web.SetValue('_ParentProc_',p_web.formsettings.parentpage)
    p_web.AlertParent('UpdatePatrolAreaBoundary')
    p_web.SetValue('_ParentProc_','')
    p_web.SetValue('_parentrid_',parentrid_)
  Else
    p_web.AlertParent('UpdatePatrolAreaBoundary')
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
  of upper('PointMap')
    do Validate::PointMap
    loc:done = 1
  of ''
    case upper(p_web.GetValue('_calledfrom_'))
    end
  end
  If loc:done = 0
    p_web.PushEvent('gainfocus')
    p_web.SetValue('_parentProc_',p_web.SetParent(loc:parent,'UpdatePatrolAreaBoundary'))
    p_web.PopEvent()
  end

! ---------------------------------------------------------------------------------------------------
! This code runs before the record is loaded. For code after the record is loaded see the PreInsert, PreCopy, PreUpdate and so on
InitForm       Routine
  DATA
LF  &FILE
  CODE
  p_web.SetValue('UpdatePatrolAreaBoundary_form:inited_',1)
  p_web.formsettings.file = 'PatrolAreaBoundary'
  p_web.formsettings.key = 'Ptb:GuidKey'
  do RestoreMem

SetFormSettings  routine
  data
  code
  If p_web.Formstate = ''
    p_web.formsettings.file = 'PatrolAreaBoundary'
    p_web.formsettings.key = 'Ptb:GuidKey'
      clear(p_web.formsettings.FieldName)
    p_web.formsettings.recordid[1] = Ptb:Guid
    p_web.formsettings.FieldName[1] = 'Ptb:Guid'
    do SetAction
    if p_web.GetSessionValue('UpdatePatrolAreaBoundary:Primed') = 1 or Ans = Net:ChangeRecord
      p_web.formsettings.action = Net:ChangeRecord
    Else
      p_web.formsettings.action = Loc:Act
    End
    p_web.formsettings.OriginalAction = Loc:Act
    If p_web.GetValue('_parentPage') <> ''
      p_web.formsettings.parentpage = p_web.GetValue('_parentPage')
    else
      p_web.formsettings.parentpage = 'UpdatePatrolAreaBoundary'
    end
    p_web.formsettings.proc = 'UpdatePatrolAreaBoundary'
    clear(p_web.formsettings.target)
    p_web.FormState = p_web.AddSettings()
  end

CancelForm  Routine
  IF p_web.GetSessionValue('UpdatePatrolAreaBoundary:Primed') = 1
    p_web.DeleteFile(PatrolAreaBoundary)
    p_web.SetSessionValue('UpdatePatrolAreaBoundary:Primed',0)
  End
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Active',0)

SendMessage Routine
  p_web.Message('Alert',loc:alert,p_web.site.MessageClass,Net:Send,1)

SetPics  Routine
  p_web.SetValue('UpdateFile','PatrolAreaBoundary')
  p_web.SetValue('UpdateKey','Ptb:GuidKey')
  If p_web.IfExistsValue('Ptb:PatGuid')
    p_web.SetPicture('Ptb:PatGuid','@s20')
  End
  p_web.SetSessionPicture('Ptb:PatGuid','@s20')
  If p_web.IfExistsValue('Ptb:Order')
    p_web.SetPicture('Ptb:Order','@n-14')
  End
  p_web.SetSessionPicture('Ptb:Order','@n-14')
  If p_web.IfExistsValue('Ptb:Description')
    p_web.SetPicture('Ptb:Description','@s100')
  End
  p_web.SetSessionPicture('Ptb:Description','@s100')
  If p_web.IfExistsValue('Ptb:Latitude')
    p_web.SetPicture('Ptb:Latitude','@s20')
  End
  p_web.SetSessionPicture('Ptb:Latitude','@s20')
  If p_web.IfExistsValue('Ptb:Longitude')
    p_web.SetPicture('Ptb:Longitude','@s20')
  End
  p_web.SetSessionPicture('Ptb:Longitude','@s20')

AfterLookup Routine
  loc:TabNumber = -1
  If  true
    loc:TabNumber += 1
  End ! Tab Condition
  Case p_Web.GetValue('lookupfield')
  Of 'Ptb:PatGuid'
    p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',Loc:TabNumber)   !
    if loc:LookupDone
      p_web.FileToSessionQueue(PatrolArea)
      p_web.SetSessionValue('Ptb:PatGuid',Pat:Guid)
    End
  End
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
    p_web.SetSessionValue('UpdatePatrolAreaBoundary_CurrentAction',Net:ViewRecord)
  Else
    Case p_web.GetSessionValue('UpdatePatrolAreaBoundary_CurrentAction')
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
    loc:formaction = p_web.getsessionvalue('SaveReferUpdatePatrolAreaBoundary')
  End
  if p_web.GetValue('_ChainToPage_') <> ''
    loc:formaction = p_web.GetValue('_ChainToPage_')
    p_web.SetSessionValue('UpdatePatrolAreaBoundary_ChainTo',loc:FormAction)
    loc:formactiontarget = '_self'
  ElsIf p_web.IfExistsSessionValue('UpdatePatrolAreaBoundary_ChainTo')
    loc:formaction = p_web.GetSessionValue('UpdatePatrolAreaBoundary_ChainTo')
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
  do Refresh::Ptb:PatGuid
  do Refresh::Ptb:Order
  do Refresh::Ptb:Description
  do Refresh::Ptb:Latitude
  do Refresh::Ptb:Longitude
  do Refresh::PointMap
  p_web.Script('$(''#'&clip(loc:formname)&''').find(''#FormState'').val('''&clip(p_web.FormState)&''');' & p_web.CRLF)
  p_web.ntForm(loc:formname,'show')

PopulateData  Routine

GenerateForm  Routine
  data
loc:disabled  Long
loc:pos       Long
  code
  p_web.ClearBrowse('UpdatePatrolAreaBoundary')
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
      packet.append('<div id="'&  lower('Tab_UpdatePatrolAreaBoundary') & '_div" class="' & p_web.combine(p_web.site.style.FormTabOuter,,' nt-tab-carousel') & '">')
    of Net:Web:TaskPanel
    of Net:Web:Wizard
      packet.append(p_web.DivHeader('Tab_UpdatePatrolAreaBoundary',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    Else
      packet.append(p_web.DivHeader('Tab_UpdatePatrolAreaBoundary',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    End
    Case loc:TabStyle
    of Net:Web:Tab
      packet.append('<ul class="'&p_web.combine(p_web.site.style.FormTabTitle,)&'">'& p_web.CRLF)
      If  true
        packet.append('<li><a href="#' & lower('tab_UpdatePatrolAreaBoundary0_div') & '">' & '<div>' & p_web.Translate('General',true)&'</div></a></li>'& p_web.CRLF) !a
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
          packet.append('<div id="UpdatePatrolAreaBoundary_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdatePatrolAreaBoundary_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolAreaBoundary')) !f1
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolAreaBoundary')) !f2
        End
        loc:javascript = ''
        packet.append(p_web.CreateStdButton('button',Net:Web:SaveButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdatePatrolAreaBoundary',1)) !f3
        loc:javascript = ''
        if loc:popup
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdatePatrolAreaBoundary')) !f5
        else
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdatePatrolAreaBoundary')) !f6
        end
        packet.append('</div>'  & p_web.CRLF) ! end id="UpdatePatrolAreaBoundary_saveset"
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdatePatrolAreaBoundary_saveset','controlgroup',loc:options)
        End
      ElsIf loc:ViewOnly = 1 and (loc:AutoSave=0 or loc:Act <> Net:ChangeRecord)
        If loc:TabStyle = Net:Web:Wizard
          packet.append('<div id="UpdatePatrolAreaBoundary_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdatePatrolAreaBoundary_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolAreaBoundary')) !f8
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolAreaBoundary')) !f9
        End
        loc:javascript = ''
        if loc:popup
          loc:javascript = clip(loc:javascript) & 'ntd.close();'
          packet.append(p_web.CreateStdButton('button',Net:Web:CloseButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolAreaBoundary')) !f10
        else
          packet.append(p_web.CreateStdButton('submit',Net:Web:CloseButton,loc:formname,loc:formactioncancel,loc:formactioncanceltarget,,,,,'UpdatePatrolAreaBoundary')) !f11
        end
        packet.append('</div>' & p_web.CRLF)
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdatePatrolAreaBoundary_saveset','controlgroup',loc:options)
        End
      End
  if loc:retrying
    p_web.SetValue('SelectField',clip(loc:formname) & '.' & p_web.GetValue('retryfield'))
  Elsif p_web.IfExistsValue('Select_btn')
    If upper(p_web.getvalue('LookupFile'))='PATROLAREA'
      If  true
          If Not (1=0)
            If loc:noFocus = false
              p_web.SetValue('SelectField',clip(loc:formname) & '.Ptb:Order')
            End
          End
      End ! Tab Condition
    End
  End
    loc:options.Free(True)
    Case loc:TabStyle
    of Net:Web:Accordion
      p_web.SetOption(loc:options,'heightStyle','content')
      p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary')>0,p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary'),'0'))
      p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdatePatrolAreaBoundary_tabchanged'',$(this).accordion("option","active")); }')
      p_web.jQuery('#' & lower('Tab_UpdatePatrolAreaBoundary') & '_div','accordion',loc:options)
    of Net:Web:TaskPanel
    of Net:Web:Tab
      p_web.SetOption(loc:options,'activate','function(event,ui){{TabChanged(''UpdatePatrolAreaBoundary_tabchanged'',$(this).tabs("option","active"));}')
      p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary')>0,p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary'),'0'))
      p_web.jQuery('#' & lower('Tab_UpdatePatrolAreaBoundary') & '_div','tabs',loc:options)
    of Net:Web:Wizard
       p_web.SetOption(loc:options,'procedure',lower('UpdatePatrolAreaBoundary'))
       p_web.SetOption(loc:options,'popup',loc:popup)
  
       p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary')>0,p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary'),0))
       p_web.SetOption(loc:options,'ntform', '#' & clip(loc:formname))
       p_web.ntWiz('UpdatePatrolAreaBoundary',loc:options)
    of Net:Web:Carousel
       p_web.SetOption(loc:options,'id',lower('tab_UpdatePatrolAreaBoundary_div'))
       p_web.SetOption(loc:options,'dots','^true')
       p_web.SetOption(loc:options,'autoplay','^false')
       p_web.jQuery('#' & lower('tab_UpdatePatrolAreaBoundary_div'),'slick',loc:options)
    end
    do SendPacket
  packet.append('</form>'&p_web.CRLF)
  do SendPacket
  loc:options.Free(True)
  If p_web.CanCallAddSec() = net:ok
    p_web.SetOption(loc:options,'addsec','UpdatePatrolAreaBoundary')
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
      p_web.RenameValue('_parentProc_',']]_parentProc_')
      p_web.SetValue('_CallPopups',1)
      If p_web.Ajax = 0 and p_web.GetPreCall('BrowsePatrolArea') = 0 then BrowsePatrolArea(p_web). ! Form field lookup proc
      p_web.RenameValue(']]_parentProc_','_parentProc_')
      p_web.SetValue('_CallPopups',0)
    do AutoLookups
    p_web.AddPreCall('UpdatePatrolAreaBoundary')
    p_web.SetValue('_popup_',0)
    p_web.PopEvent()
  End

ntForm Routine
  data
loc:BuildOptions                stringTheory
  code
  p_web.SetOption(loc:options,'id',clip(loc:formname))
  p_web.SetOption(loc:options,'procedure', lower('UpdatePatrolAreaBoundary'))
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
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdatePatrolAreaBoundary0',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_UpdatePatrolAreaBoundary0_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate('General')&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdatePatrolAreaBoundary0',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_UpdatePatrolAreaBoundary0',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_UpdatePatrolAreaBoundary0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="0"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_UpdatePatrolAreaBoundary0_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-tab-carousel-header',)&'">'&|
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_UpdatePatrolAreaBoundary0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-rounded-header ui-corner-all',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_UpdatePatrolAreaBoundary0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend,,,1) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset"><legend class="'&p_web.combine(' nt-plain-legend',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</legend>' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_UpdatePatrolAreaBoundary0',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('UpdatePatrolAreaBoundary_container',p_web.combine(,),,loc:LayoutMethod))
      do SendPacket
      If  loc:parent <> 'updatepatrolarea'                                !c1
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Ptb:PatGuid_row')) ,p_web.Combine(lower(' UpdatePatrolAreaBoundary-Ptb:PatGuid-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Ptb:PatGuid
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
        do Value::Ptb:PatGuid
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Ptb:PatGuid
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
      end   !c1
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Ptb:Order_row')) ,p_web.Combine(lower(' UpdatePatrolAreaBoundary-Ptb:Order-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Ptb:Order
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
        do Value::Ptb:Order
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Ptb:Order
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Ptb:Description_row')) ,p_web.Combine(lower(' UpdatePatrolAreaBoundary-Ptb:Description-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Ptb:Description
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
        do Value::Ptb:Description
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Ptb:Description
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Ptb:Latitude_row')) ,p_web.Combine(lower(' UpdatePatrolAreaBoundary-Ptb:Latitude-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Ptb:Latitude
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
        do Value::Ptb:Latitude
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Ptb:Latitude
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Ptb:Longitude_row')) ,p_web.Combine(lower(' UpdatePatrolAreaBoundary-Ptb:Longitude-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Ptb:Longitude
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
        do Value::Ptb:Longitude
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Ptb:Longitude
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('PointMap_row')) ,p_web.Combine(lower(' UpdatePatrolAreaBoundary-PointMap-row'),,), , , ,, loc:LayoutMethod)) !j1
          if loc:columncounter > loc:maxcolumns then loc:maxcolumns = loc:columncounter.
          loc:columncounter = 0
          loc:rowstarted = 1
        end
        do SendPacket
        loc:width = ''
        If loc:cellstarted = 0
          If loc:maxcolumns = 0
            loc:maxcolumns = 3
          End
          packet.append(p_web.FormTableCellStart( ,p_web.Combine(,),,loc:maxcolumns,, , , loc:LayoutMethod,net:CellTypeOnly)) !2
          do SendPacket
          loc:cellstarted = 1
          loc:FirstInCell = 1
        Else
          loc:FirstInCell = 0
        End
        do Value::PointMap
          do Comment::PointMap
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
        packet.append(p_web.FormTableEnd('UpdatePatrolAreaBoundary_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('UpdatePatrolAreaBoundary_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('UpdatePatrolAreaBoundary_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolAreaBoundary0'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary')>0,p_web.GetSessionValue('showtab_UpdatePatrolAreaBoundary'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdatePatrolAreaBoundary_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_UpdatePatrolAreaBoundary0_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolAreaBoundary0'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolAreaBoundary0'))
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
    loc:Heading = p_web.Translate('Update Patrol Area Boundary',(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
  End
  If p_web.site.HeaderBackButton and (loc:inNetWebPopup or loc:popup)
    loc:Heading = p_web.AddHeaderBackButton(loc:Heading,,)
  End
  If loc:inNetWebPopup = 1
    exit
  end
  If loc:Heading
    If loc:popup
      p_web.SetPopupDialogHeading('UpdatePatrolAreaBoundary',clip(loc:Heading),(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
    Else
      packet.append(lower('<div id="form-access-UpdatePatrolAreaBoundary"></div>'))
        p_web.DivHeader('UpdatePatrolAreaBoundary_header',p_web.combine(p_web.site.style.formheading,))
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

Refresh::Ptb:PatGuid  Routine
  do Prompt::Ptb:PatGuid
  do Value::Ptb:PatGuid
  do Comment::Ptb:PatGuid

AutoComplete::Ptb:PatGuid  Routine
  data
recs  long
loc:Filter   StringTheory
  code
  pushbind()
  p_web.OpenFile(PatrolAreaBoundary)
  bind(Ptb:Record)
  p_web.OpenFile(PatrolArea)
  bind(Pat:Record)
  If p_web.sqlsync then p_web.SqlWait(p_web.SqlName).
  open(Ptb:PatGuid_OptionView)
  loc:Filter.SetValue('')
  Ptb:PatGuid_OptionView{prop:order} = p_web.CleanFilter(Ptb:PatGuid_OptionView,'UPPER(Pat:Name)')
  loc:Filter.Append(p_web.CleanFilter(Ptb:PatGuid_OptionView,p_web.MakeFilter(clip(''),p_web.GetValue('_term_'),'Pat:Name',Net:Contains,0)))
  Ptb:PatGuid_OptionView{prop:filter} = p_web.AssignFilter(loc:Filter.GetValue())
  Set(Ptb:PatGuid_OptionView)
  packet.append('[')
  Loop
    Next(Ptb:PatGuid_OptionView)
    If ErrorCode() then Break.
    recs += 1
    packet.append(choose(recs=1,'',',') & '"' & p_web.JsonOK(p_web.AsciiToUtf(Pat:Name)) & '"')
    If recs >= 20
      Break
    End
  End
  packet.append(']')
  Close(Ptb:PatGuid_OptionView)
  If p_web.sqlsync then p_web.SqlRelease(p_web.SqlName).
  p_Web.CloseFile(PatrolAreaBoundary)
  p_Web.CloseFile(PatrolArea)
  PopBind()
  p_web.SendJSON(packet)

Prompt::Ptb:PatGuid  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:PatGuid') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Pat Guid:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Ptb:PatGuid')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Ptb:PatGuid')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Ptb:PatGuid Routine
        p_web.OpenFile(PatrolArea)
  ! GetDescription resets the 'NewValue' to the code, if the description is found. Returns 1 if code valid.
  If p_web.Ajax = 1 and p_web.ifExistsValue('Value')
    if p_web.GetBrowseValue(p_web.GetValue('Value'),Net:Web:Record)
      p_web.DeleteValue('value')
      loc:ok = 1
    else
      loc:ok = p_web.GetDescription(PatrolArea,Pat:GuidKey,Pat:NameKey,Pat:Guid,Pat:Name,p_web.GetValue('Value')) !7
    end
  Else
    loc:ok = p_web.GetDescription(PatrolArea,Pat:GuidKey,Pat:NameKey,Pat:Guid,Pat:Name,p_web.GetSessionValue('Ptb:PatGuid')) !7
  End
  if loc:ok then loc:lookupdone = 1.
  p_web.CloseFile(PatrolArea)  !cf
  If p_web.IfExistsValue('NewValue') then p_web.SetValue('Value',p_web.GetValue('NewValue')).
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Ptb:PatGuid = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
    Ptb:PatGuid = p_web.GetValue('Value')
  ElsIf p_web.Ajax = 1 and p_web.IfExistsValue('Pat:Guid')
    Ptb:PatGuid = p_web.GetValue('Pat:Guid')
  ElsIf p_web.Ajax = 1
    Ptb:PatGuid = Pat:Guid
  End
  do ValidateValue::Ptb:PatGuid  ! copies value to session value if valid.
  p_Web.SetValue('lookupfield','Ptb:PatGuid')
  do AfterLookup
  p_web.PushEvent('parentupdated')
  do Refresh::Ptb:PatGuid   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Ptb:PatGuid  Routine
  If  loc:parent <> 'updatepatrolarea'                                    !c2
          If loc:invalid = '' then p_web.SetSessionValue('Ptb:PatGuid',Ptb:PatGuid).
  End                      !c2

Value::Ptb:PatGuid  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Ptb:PatGuid') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine('nt-lookup ' & p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:PatGuid') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Ptb:PatGuid = p_web.RestoreValue('Ptb:PatGuid')
    do ValidateValue::Ptb:PatGuid
    If Ptb:PatGuid:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Ptb:PatGuid
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    loc:lookuponly = ''
          p_web.OpenFile(PatrolArea)
    ! GetDescription resets the 'NewValue' to the code, if the description is found. Returns 1 if code valid.
    loc:ok = p_web.GetDescription(PatrolArea,Pat:GuidKey,Pat:NameKey,Pat:Guid,Pat:Name,p_web.GetSessionValue('Ptb:PatGuid')) !3
      p_web.FileToSessionQueue(PatrolArea)
    p_web.CloseFile(PatrolArea)  !cf
    loc:extra = clip(loc:extra) & ' data-nt-desc="name" data-nt-lut="patrolarea"'
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Ptb:PatGuid')&''').val('''&p_web._jsok(p_web.GetSessionValue('Pat:Name'))&''');')
    else
      If not loc:viewonly and not loc:readonly
        loc:fieldclass = 'nt-lookup-entry ' & loc:fieldclass
      End
      packet.append(p_web.CreateInput('text','Ptb:PatGuid',p_web.GetSessionValue('Pat:Name'),loc:fieldclass,loc:readonly & ' ' & loc:lookuponly,clip(loc:extra) & ' ' & clip(loc:autocomplete),'@s20',loc:javascript,,,'Ptb:PatGuid',,'imm',,,,'UpdatePatrolAreaBoundary',,,'autocomplete')  & p_web.CRLF) !4a
      if not loc:viewonly and not loc:readonly
        loc:fieldclass = ''
          packet.append(p_web.CreateStdButton('button',Net:Web:LookupButton,loc:formname,,,'ntd.push(''BrowsePatrolArea'','''&p_web.nocolon('Ptb:PatGuid')&''','''&p_web.jsParm(p_web.translate('Select PatrolArea'))&''',1,'&Net:LookupRecord&',''Pat:Name'',''UpdatePatrolAreaBoundary'','''','''')',,,loc:fieldclass,'UpdatePatrolAreaBoundary')) !b3
    ! FormFieldAutoComplete = 1
      loc:options.Free(True)
      p_web.SetOption(loc:options,'source','function(req,res){{$.getJSON("'&p_web.nocolon(lower('UpdatePatrolAreaBoundary_Ptb:PatGuid_value'))&'","_event_=newselection&_ajax_=1&_term_="+req.term,function(data){{res(data);})}')
      p_web.SetOption(loc:options,'minLength',2)
      p_web.SetOption(loc:options,'delay',300)
      p_web.SetOption(loc:options,'select','function(e, ui) {{ $("#' & p_web.nocolon('Ptb:PatGuid') & '").attr("data-ac","select") }')
      p_web.SetOption(loc:options,'open','function(e, ui) {{ $("#' & p_web.nocolon('Ptb:PatGuid') & '").attr("data-ac","open") }')
      p_web.SetOption(loc:options,'close','function(e, ui) {{ var x=  $("#' & p_web.nocolon('Ptb:PatGuid') & '").attr("data-ac"); $("#' & p_web.nocolon('Ptb:PatGuid') & '").attr("data-ac","close");if (x=="select"){{$("#' & p_web.nocolon('Ptb:PatGuid') & '").trigger("change") };}')
      p_web.SetOption(loc:options, 'classes','{{"ui-autocomplete":"nt-autocomplete-droplist"}')
      p_web.jQuery('#Ptb:PatGuid','autocomplete',loc:options)
      End
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Ptb:PatGuid  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Ptb:PatGuid:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:PatGuid') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:PatGuid') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Ptb:Order  Routine
  do Prompt::Ptb:Order
  do Value::Ptb:Order
  do Comment::Ptb:Order

Prompt::Ptb:Order  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Order') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Order:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Ptb:Order')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Ptb:Order')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Ptb:Order Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Ptb:Order = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @n-14
    Ptb:Order = p_web.DeformatValue(p_web.GetValue('Value'),'@n-14')
  End
  do ValidateValue::Ptb:Order  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Ptb:Order   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Ptb:Order  Routine
          If Numeric(Ptb:Order) = 0
            loc:Invalid = 'Ptb:Order'
            Ptb:Order:IsInvalid = true
            if not loc:alert then loc:alert = p_web.translate('Order:') & ' ' & p_web.site.NumericText.
          End
          If loc:invalid = '' then p_web.SetSessionValue('Ptb:Order',Ptb:Order).

Value::Ptb:Order  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Ptb:Order') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Order') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Number
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Ptb:Order = p_web.RestoreValue('Ptb:Order')
    do ValidateValue::Ptb:Order
    If Ptb:Order:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- NUMBER --- Ptb:Order
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Ptb:Order')&''').val('''&p_web._jsok(p_web.GetSessionValue('Ptb:Order'))&''');')
    Else
      packet.append(p_web.CreateInput('number','Ptb:Order',p_web.GetSessionValue('Ptb:Order'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@n-14'),,'Ptb:Order',,'imm',,,,'UpdatePatrolAreaBoundary')  & p_web.CRLF)
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Ptb:Order  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Ptb:Order:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
    loc:comment = p_web._jsok(p_web.site.NumericText)
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Order') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Order') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Ptb:Description  Routine
  do Prompt::Ptb:Description
  do Value::Ptb:Description
  do Comment::Ptb:Description

Prompt::Ptb:Description  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Description') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Description:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Ptb:Description')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Ptb:Description')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Ptb:Description Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Ptb:Description = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s100
    Ptb:Description = p_web.DeformatValue(p_web.GetValue('Value'),'@s100')
  End
  do ValidateValue::Ptb:Description  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Ptb:Description  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Ptb:Description',Ptb:Description).

Value::Ptb:Description  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Ptb:Description') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Description') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Ptb:Description = p_web.RestoreValue('Ptb:Description')
    do ValidateValue::Ptb:Description
    If Ptb:Description:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Ptb:Description
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Ptb:Description')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Ptb:Description'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Ptb:Description',p_web.GetSessionValueFormat('Ptb:Description'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s100'),,'Ptb:Description',,'',,,,'UpdatePatrolAreaBoundary')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Ptb:Description  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Ptb:Description:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Description') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Description') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Ptb:Latitude  Routine
  do Prompt::Ptb:Latitude
  do Value::Ptb:Latitude
  do Comment::Ptb:Latitude

Prompt::Ptb:Latitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Latitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Latitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Ptb:Latitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Ptb:Latitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Ptb:Latitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Ptb:Latitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s20
    Ptb:Latitude = p_web.DeformatValue(p_web.GetValue('Value'),'@s20')
  End
  do ValidateValue::Ptb:Latitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Ptb:Latitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Ptb:Latitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Ptb:Latitude',Ptb:Latitude).

Value::Ptb:Latitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Ptb:Latitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Latitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Ptb:Latitude = p_web.RestoreValue('Ptb:Latitude')
    do ValidateValue::Ptb:Latitude
    If Ptb:Latitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Ptb:Latitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Ptb:Latitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Ptb:Latitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Ptb:Latitude',p_web.GetSessionValueFormat('Ptb:Latitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s20'),,'Ptb:Latitude',,'imm',,,,'UpdatePatrolAreaBoundary')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Ptb:Latitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Ptb:Latitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Latitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Latitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Ptb:Longitude  Routine
  do Prompt::Ptb:Longitude
  do Value::Ptb:Longitude
  do Comment::Ptb:Longitude

Prompt::Ptb:Longitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Longitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Longitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Ptb:Longitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Ptb:Longitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Ptb:Longitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Ptb:Longitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s20
    Ptb:Longitude = p_web.DeformatValue(p_web.GetValue('Value'),'@s20')
  End
  do ValidateValue::Ptb:Longitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Ptb:Longitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Ptb:Longitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Ptb:Longitude',Ptb:Longitude).

Value::Ptb:Longitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Ptb:Longitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Longitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Ptb:Longitude = p_web.RestoreValue('Ptb:Longitude')
    do ValidateValue::Ptb:Longitude
    If Ptb:Longitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Ptb:Longitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Ptb:Longitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Ptb:Longitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Ptb:Longitude',p_web.GetSessionValueFormat('Ptb:Longitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s20'),,'Ptb:Longitude',,'imm',,,,'UpdatePatrolAreaBoundary')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Ptb:Longitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Ptb:Longitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Longitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolAreaBoundary_' & p_web.nocolon('Ptb:Longitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::PointMap  Routine
  do Value::PointMap
  do Comment::PointMap



Validate::PointMap Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
  End
  do ValidateValue::PointMap  ! copies value to session value if valid.
  If loc:invalid = ''
    Case p_web.event
    Of 'zoomed'
    Of 'clicked'
      p_web.StoreValue('Ptb:Latitude','_lat_')
      p_web.StoreValue('Ptb:Longitude','_lng_')
    Of 'gainfocus' ! returned from form
      Case lower(p_web.GetValue('_cluster_'))
      End ! Case lower(p_web.GetValue('_from_'))

    Of 'dragged'  ! marker on map was dragged
      Case lower(p_web.GetValue('_cluster_'))
      of lower('undefined')
        p_web.StoreValue('Ptb:Latitude','_lat_')
        p_web.StoreValue('Ptb:Longitude','_lng_')
      End ! Case lower(p_web.GetValue('_cluster_'))
    End
  End
  p_web.PushEvent('parentupdated')
  do SendMessage
  do Refresh::Ptb:Latitude  !(GenerateFieldReset)
  do Refresh::Ptb:Longitude  !(GenerateFieldReset)
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::PointMap  Routine

Value::PointMap  Routine
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
  If p_web.GetValue('_name_') = p_web.nocolon('PointMap') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('PointMap') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Map
  If loc:retrying
    do ValidateValue::PointMap
    If PointMap:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- MAP --- 
    loc:MapProvider = p_web.Site.MapProvider
    loc:url = ''
    packet.append(p_web.CreateMapDiv('PointMap',,600,300)  & p_web.CRLF)
    ! Options for the leaflet.js map object
    loc:MapOptions.SetValue('')
    p_web.SetOption(loc:MapOptions,'center','['&p_web.GetLatLng(p_web.GetSessionValue('Ptb:Latitude')) &',' & p_web.GetLatLng(p_web.GetSessionValue('Ptb:Longitude')) &']')
    p_web.SetOption(loc:MapOptions,'zoom',p_web.SetMapZoom(loc:MapProvider,p_web.GSV('Pat:Zoom')))
    ! Options for the Scale
    loc:ScaleOptions.Free(true)
    p_web.SetOption(loc:ScaleOptions,'maxWidth',100)
    p_web.SetOption(loc:ScaleOptions,'metric',1)
    p_web.SetOption(loc:ScaleOptions,'imperial',1)
    ! options for the leaflet.js tiles layer
    p_web.SetMapDevIdOptions(loc:MapProvider,loc:TileOptions)
    ! options for the nettalk ntmap object (which takes the map and tiles options from above).
    loc:options.Free(True)
    p_web.SetOption(loc:options,'procedure','UpdatePatrolAreaBoundary')
    If p_web.Site.ConnectionSecure
      p_web.SetOption(loc:options,'ssl',1)
    End
    p_web.SetOption(loc:options,'equate','PointMap')
    p_web.SetOption(loc:options,'provider',loc:MapProvider)
    p_web.SetOption(loc:options,'divId',p_web.NoColon('PointMap'))
    p_web.SetOption(loc:options,'tileURL',loc:url)
    p_web.SetOption(loc:options,'mapOptions',p_web.WrapOptions(loc:mapOptions))
    p_web.SetOption(loc:options,'tileOptions',p_web.WrapOptions(loc:tileOptions))
    p_web.SetOption(loc:options,'moveHomeToClick','true')
    p_web.SetOption(loc:options,'scale',1)
    p_web.SetOption(loc:options,'scaleOptions',p_web.WrapOptions(loc:scaleOptions))
    p_web.ntMap('PointMap',loc:options)
    ! map marker at start position
    loc:options.Free(True)
    If p_web.Site.MapDefaultMarker
      p_web.SetOption(loc:options,'icon','^' & clip(p_web.Site.MapDefaultMarker))
    End
    p_web.SetOption(loc:options,'draggable','true')
    p_web.ntMap('PointMap','addMarkerToMap','_home_', p_web.GetLatLng(Ptb:Latitude) , p_web.GetLatLng(Ptb:Longitude) , p_web.WrapOptions(loc:options) , p_web._jsok(Ptb:Description, Net:HtmlOk*0+Net:UnsafeHtmlOk*0) , '1')
  
    !--  Map Data  ---------------------------------------------------
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::PointMap  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if PointMap:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolAreaBoundary_' & p_web.nocolon('PointMap') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolAreaBoundary_' & p_web.nocolon('PointMap') & '_comment_div").html("'&clip(loc:comment)&'");')
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
  of lower('UpdatePatrolAreaBoundary_nexttab_' & 0)
    Ptb:PatGuid = p_web.GetSessionValue('Ptb:PatGuid')
    do ValidateValue::Ptb:PatGuid
    If loc:Invalid
      loc:retrying = 1
      do Value::Ptb:PatGuid
      do Comment::Ptb:PatGuid ! allows comment style to be updated.
    End
    Ptb:Order = p_web.GetSessionValue('Ptb:Order')
    do ValidateValue::Ptb:Order
    If loc:Invalid
      loc:retrying = 1
      do Value::Ptb:Order
      do Comment::Ptb:Order ! allows comment style to be updated.
    End
    Ptb:Description = p_web.GetSessionValue('Ptb:Description')
    do ValidateValue::Ptb:Description
    If loc:Invalid
      loc:retrying = 1
      do Value::Ptb:Description
      do Comment::Ptb:Description ! allows comment style to be updated.
    End
    Ptb:Latitude = p_web.GetSessionValue('Ptb:Latitude')
    do ValidateValue::Ptb:Latitude
    If loc:Invalid
      loc:retrying = 1
      do Value::Ptb:Latitude
      do Comment::Ptb:Latitude ! allows comment style to be updated.
    End
    Ptb:Longitude = p_web.GetSessionValue('Ptb:Longitude')
    do ValidateValue::Ptb:Longitude
    If loc:Invalid
      loc:retrying = 1
      do Value::Ptb:Longitude
      do Comment::Ptb:Longitude ! allows comment style to be updated.
    End
    If loc:Invalid then exit.
  End
  p_web.ntWiz('UpdatePatrolAreaBoundary','next')

ChangeTab  routine
  p_web.ChangeTab(loc:TabStyle,'UpdatePatrolAreaBoundary',loc:TabTo)

TabChanged  routine
  data
TabNumber   Long   !! remember that tabs are numbered from 0
TabHeading  String(252),dim(1)
  code
  tabnumber = p_web.GetValue('_tab_')
  tabheading[1]  = p_web.Translate('General')
  p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',tabnumber) !! remember that tabs are numbered from 0

CallDiv    routine
  data
  code
  p_web.Ajax = 1
  p_web.PageName = p_web._unEscape(p_web.PageName)
  case lower(p_web.PageName)
  of lower('UpdatePatrolAreaBoundary') & '_tabchanged'
     do TabChanged
  of lower('UpdatePatrolAreaBoundary_tab_' & 0)
    do GenerateTab0
  of lower('UpdatePatrolAreaBoundary_Ptb:PatGuid_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Ptb:PatGuid
        do AlertParent
      of 'newselection' !EVENT:NewSelection !2
        do AutoComplete::Ptb:PatGuid
      of 'timer'
        do refresh::Ptb:PatGuid
        do AlertParent
      else
        do Value::Ptb:PatGuid
      end
  of lower('UpdatePatrolAreaBoundary_Ptb:Order_value')
      case p_web.Event ! Number
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Ptb:Order
        do AlertParent
      of 'timer'
        do refresh::Ptb:Order
        do AlertParent
      else
        do Value::Ptb:Order
      end
  of lower('UpdatePatrolAreaBoundary_Ptb:Description_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Ptb:Description
        do AlertParent
      of 'timer'
        do refresh::Ptb:Description
        do AlertParent
      else
        do Value::Ptb:Description
      end
  of lower('UpdatePatrolAreaBoundary_Ptb:Latitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Ptb:Latitude
        do AlertParent
      of 'timer'
        do refresh::Ptb:Latitude
        do AlertParent
      else
        do Value::Ptb:Latitude
      end
  of lower('UpdatePatrolAreaBoundary_Ptb:Longitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Ptb:Longitude
        do AlertParent
      of 'timer'
        do refresh::Ptb:Longitude
        do AlertParent
      else
        do Value::Ptb:Longitude
      end
  of lower('UpdatePatrolAreaBoundary_PointMap_value')
      case p_web.Event ! Map
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::PointMap
        do AlertParent
      of 'zoomed'
      orof 'moved'
      orof 'dragged'
      orof 'clicked'
        do Validate::PointMap
        do AlertParent
      of 'timer'
        do refresh::PointMap
        do Refresh::Ptb:Latitude
        do Refresh::Ptb:Longitude
        do AlertParent
      else
        do Value::PointMap
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
  p_web.SetValue('UpdatePatrolAreaBoundary_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Active',1)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary_CurrentAction',Net:InsertRecord)
  p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',0)   !
  Clear(Ptb:record) ! Primes moved before auto-increment (PrimeRecord) call.
  Ptb:Guid = glo:st.Random(16,st:Upper+st:Number)            ! taken from dictionary initial value
  p_web.SetSessionValue('Ptb:Guid',Ptb:Guid)
  Ptb:PatGuid = p_web.GSV('Pat:Guid')
  p_web.SetSessionValue('Ptb:PatGuid',Ptb:PatGuid)    ! taken from priming tab
  Ptb:Latitude = p_web.GSV('Pat:Latitude')
  p_web.SetSessionValue('Ptb:Latitude',Ptb:Latitude)    ! taken from priming tab
  Ptb:Longitude = p_web.GSV('Pat:Longitude')
  p_web.SetSessionValue('Ptb:Longitude',Ptb:Longitude)    ! taken from priming tab
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreCopy  Routine
  data
  code
  p_web.SetValue('UpdatePatrolAreaBoundary_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Active',1)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary_CurrentAction',Net:CopyRecord)
  p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',0)  !
  p_web._PreCopyRecord(PatrolAreaBoundary,Ptb:GuidKey)
  Ptb:Guid = glo:st.Random(16,st:Upper+st:Number)
  p_web.SetSessionValue('Ptb:Guid',Ptb:Guid)
  ! here we need to copy the non-unique fields across
  Ptb:PatGuid = p_web.GSV('Pat:Guid')
  p_web.SetSessionValue('Ptb:PatGuid',Ptb:PatGuid)
  Ptb:Latitude = p_web.GSV('Pat:Latitude')
  p_web.SetSessionValue('Ptb:Latitude',Ptb:Latitude)
  Ptb:Longitude = p_web.GSV('Pat:Longitude')
  p_web.SetSessionValue('Ptb:Longitude',Ptb:Longitude)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
! this code runs After the record is loaded. To run code before, see InitForm Routine
PreUpdate  Routine
  data
loc:offset      Long
  code
  p_web.SetValue('UpdatePatrolAreaBoundary_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Active',1)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary_CurrentAction',Net:ChangeRecord)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Primed',0)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreDelete       Routine
  data
  code
  p_web.SetValue('UpdatePatrolAreaBoundary_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary_CurrentAction',Net:DeleteRecord)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Primed',0)
  p_web.SetSessionValue('showtab_UpdatePatrolAreaBoundary',0)   !
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
LoadRelatedRecords  Routine
        p_web.OpenFile(PatrolArea)
  ! GetDescription resets the 'NewValue' to the code, if the description is found. Returns 1 if code valid.
  loc:ok = p_web.GetDescription(PatrolArea,Pat:GuidKey,Pat:NameKey,Pat:Guid,,p_web.GetSessionValue('Ptb:PatGuid')) !2
  if loc:ok then p_web.FileToSessionQueue(PatrolArea).
  p_web.CloseFile(PatrolArea)  !cf
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
    If  loc:parent <> 'updatepatrolarea'                                     !c3
          If p_web.IfExistsValue('Ptb:PatGuid')
            Ptb:PatGuid = p_web.GetValue('Ptb:PatGuid')
          End
    End    !c3
          If p_web.IfExistsValue('Ptb:Order')
            Ptb:Order = p_web.GetValue('Ptb:Order')
          End
          If p_web.IfExistsValue('Ptb:Description')
            Ptb:Description = p_web.GetValue('Ptb:Description')
          End
          If p_web.IfExistsValue('Ptb:Latitude')
            Ptb:Latitude = p_web.GetValue('Ptb:Latitude')
          End
          If p_web.IfExistsValue('Ptb:Longitude')
            Ptb:Longitude = p_web.GetValue('Ptb:Longitude')
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
  If p_web.GetSessionValue('UpdatePatrolAreaBoundary:Primed') = 0 and Ans = Net:InsertRecord
    Get(PatrolAreaBoundary,0)
    GotFileZero = true
  End
  ! Check for duplicates
  If Duplicate(Ptb:GuidKey) ! In SQL drivers this clears the Blob field, if Get(file,0) was done. TPS does not.
    loc:Invalid = 'Ptb:Guid'
    if not loc:alert then loc:Alert = clip(p_web.site.DuplicateText) & ' GuidKey --> Ptb:Guid = ' & clip(Ptb:Guid).
  End
  If GotFileZero
  End

ValidateDelete  Routine
  p_web.DeleteSessionValue('UpdatePatrolAreaBoundary_ChainTo')
  ! Check for restricted child records

ValidateRecord  Routine
  p_web.DeleteSessionValue('UpdatePatrolAreaBoundary_ChainTo')

        p_web.OpenFile(PatrolArea)
  ! GetDescription resets the 'NewValue' to the code, if the description is found. Returns 1 if code valid.
  loc:ok = p_web.GetDescription(PatrolArea,Pat:GuidKey,Pat:NameKey,Pat:Guid,Pat:Name,p_web.GetValue('Ptb:PatGuid')) !4
  p_web.CloseFile(PatrolArea)  !cf
  IF loc:ok and p_web.ifExistsValue('NewValue')
    Ptb:PatGuid = p_web.GetValue('NewValue')
    p_web.SetValue('Ptb:PatGuid',Ptb:PatGuid)
  End
  ! Then add additional constraints set on the template
  loc:InvalidTab = -1
  ! tab = 1
    If  true
        loc:InvalidTab += 1
        do ValidateValue::Ptb:PatGuid
        If loc:Invalid then exit.
        do ValidateValue::Ptb:Order
        If loc:Invalid then exit.
        do ValidateValue::Ptb:Description
        If loc:Invalid then exit.
        do ValidateValue::Ptb:Latitude
        If loc:Invalid then exit.
        do ValidateValue::Ptb:Longitude
        If loc:Invalid then exit.
        do ValidateValue::PointMap
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
    p_web.InsertAgain('UpdatePatrolAreaBoundary')
    Clear(Ptb:Record)
  Else
    p_web.SetSessionValue('UpdatePatrolAreaBoundary:Active',0)
  End
PostCopy        Routine
  Data
  Code
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Primed',0)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Active',0)

PostUpdate      Routine
  Data
  Code
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Primed',0)
  p_web.SetSessionValue('UpdatePatrolAreaBoundary:Active',0)

PostDelete      Routine
