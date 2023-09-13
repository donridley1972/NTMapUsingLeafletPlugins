

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76004.INC'),ONCE        !Local module procedure declarations
                     END


UpdatePatrolArea     PROCEDURE  (NetWebServerWorker p_web,long p_stage=0)
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
Pat:Name:IsInvalid  Long
Pat:Latitude:IsInvalid  Long
Pat:Longitude:IsInvalid  Long
Pat:Zoom:IsInvalid  Long
PatrolAreaMap:IsInvalid  Long
BrowsePatrolAreaBoundary:IsInvalid  Long
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
PatrolAreaMap_MapDataView:1   View(PatrolAreaBoundary)
                                                 Project(Ptb:Latitude)
                                                 Project(Ptb:Longitude)
                                                 Project(Ptb:Order)
                                               End
  CODE
  loc:procedure = lower('UpdatePatrolArea')
  GlobalErrors.SetProcedureName('UpdatePatrolArea')
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
  loc:formname = lower('UpdatePatrolArea_frm')
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
      if p_web.Event = 'parentnewselection' or  p_web.GetValue('UpdatePatrolArea:parentIs') = 'Browse' ! allow for form used as a child of a browse, default to change mode.
        p_web.FormReady('UpdatePatrolArea','Change','Pat:Guid',p_web.GetSessionValue('Pat:Guid'))
      Else
        p_web.FormReady('UpdatePatrolArea','')
      End
    End
    if p_web.site.frontloaded and p_web.Ajax and loc:popup = 1
      loc:FrontLoading = net:GeneratingData
    else
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdatePatrolArea')
        p_web.DivHeader(p_web.site.ContentBody,p_web.site.contentbodydivclass)
      End
      p_web.DivHeader('UpdatePatrolArea',p_web.combine(p_web.site.style.formdiv,))
      p_web.DivHeader('UpdatePatrolArea_alert',p_web.combine(p_web.site.MessageClass,' nt-hidden'))
      p_web.DivFooter()
    End
    do SetPics
    if loc:FrontLoading = net:GeneratingData
      do GenerateData
    else
      do GenerateForm
      p_web.DivFooter()
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdatePatrolArea')
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
    loc:poppedup = p_web.GetValue('_UpdatePatrolArea:_poppedup_')
    if p_web.site.FrontLoaded then loc:popup = 1.
    if loc:poppedup = 0 and p_Web.Ajax = 0
      If p_web.GetPreCall('UpdatePatrolArea') = 0 and (p_web.GetValue('_CallPopups') = 0 or p_web.GetValue('_CallPopups') = 1)
        p_web.AddPreCall('UpdatePatrolArea')
        p_web.DivHeader('popup_UpdatePatrolArea','nt-hidden',,,,1,,,'popup_UpdatePatrolArea')
        p_web.DivHeader('UpdatePatrolArea',p_web.combine(p_web.site.style.formdiv,),,,,1)
        If p_web.site.FrontLoaded
          loc:frontloading = net:GeneratingPage
          do GenerateForm
        End
        p_web.DivFooter()
        p_web.DivFooter(,lower('popup_UpdatePatrolArea End'))
        do Heading
        loc:options.Free(True)
        p_web.SetOption(loc:options,'close','function(event, ui) {{ ntd.pop(); }')
        p_web.SetOption(loc:options,'autoOpen','false')
        p_web.SetOption(loc:options,'width',900)
        p_web.SetOption(loc:options,'modal','true')
        p_web.SetOption(loc:options,'title',loc:Heading)
        p_web.SetOption(loc:options,'position','{{ my: "top", at: "top+' & clip(15) & '", of: window }')
        If p_web.CanCallAddSec() = net:ok
          p_web.SetOption(loc:options,'addsec','UpdatePatrolArea')
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
        p_web.jQuery('#' & lower('popup_UpdatePatrolArea_div'),'dialog',loc:options,'.removeClass("nt-hidden")')
      End
      do popups ! includes all the other popups dependant on this procedure
      loc:poppedup = 1
      p_web.SetValue('_UpdatePatrolArea:_poppedup_',1)
    end

  of Net:Web:AfterLookup + Net:Web:Cancel
    loc:LookupDone = 0
    do AfterLookup
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdatePatrolArea')&'_div'').dialog(''close'');')
    end

  of Net:Web:AfterLookup
    loc:LookupDone = 1
    do AfterLookup

  of Net:Web:Cancel
    do CancelForm
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdatePatrolArea')&'_div'').dialog(''close'');')
    end

  of Net:InsertRecord + NET:WEB:StagePre
    if p_web._InsertAfterSave = 0
      p_web.setsessionvalue('SaveReferUpdatePatrolArea',p_web.getPageName(p_web.RequestReferer))
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
    p_web.setsessionvalue('SaveReferUpdatePatrolArea',p_web.getPageName(p_web.RequestReferer))
    do PreCopy
  of Net:CopyRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateCopy
  of Net:CopyRecord + NET:WEB:StagePost
    do RestoreMem
    do PostWrite
    do PostCopy
  of Net:CopyRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Pat:Guid') = 0 then p_web.SetValue('Pat:Guid',p_web.GetSessionValue('Pat:Guid')).
    do PreCopy
  of Net:ChangeRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdatePatrolArea',p_web.getPageName(p_web.RequestReferer))      !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolArea',0)           !
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
    If p_web.IfExistsValue('Pat:Guid') = 0 then p_web.SetValue('Pat:Guid',p_web.GetSessionValue('Pat:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolArea',0)     !
  of Net:DeleteRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdatePatrolArea',p_web.getPageName(p_web.RequestReferer))   !
    do PreDelete
  of Net:DeleteRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateDelete
  of Net:DeleteRecord + NET:WEB:StagePost
    do RestoreMem
    do PostDelete
  of Net:ViewRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Pat:Guid') = 0 then p_web.SetValue('Pat:Guid',p_web.GetSessionValue('Pat:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolArea',0)  !

  of Net:ViewRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdatePatrolArea',p_web.getPageName(p_web.RequestReferer))   !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdatePatrolArea',0)    !
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
    p_web.SetSessionValue('showtab_UpdatePatrolArea',Loc:InvalidTab)   !
  ElsIf band(p_stage,NET:WEB:StageValidate) > 0 and band(p_stage,Net:DeleteRecord) <> Net:DeleteRecord and band(p_stage,Net:WriteMask) > 0 and p_web.Ajax = 1 and loc:popup
    If p_web.IfExistsValue('_stayopen_')
    ! only a partial save, so don't complete the form.
    ElsIf loc:FormOnSave = Net:InsertAgain
      If band(loc:act,Net:InsertRecord) <> Net:InsertRecord
        p_web.script('$(''#popup_'&lower('UpdatePatrolArea')&'_div'').dialog(''close'');')
      End
    Else
      p_web.script('$(''#popup_'&lower('UpdatePatrolArea')&'_div'').dialog(''close'');')
    End
  End
  If loc:alert <> ''             !
    p_web.SetAlert(loc:alert, net:Alert + Net:Message,'UpdatePatrolArea',1)
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
    p_web.AlertParent('UpdatePatrolArea')
  Elsif p_web.formsettings.parentpage
    parentrid_ = p_web.GetValue('_parentrid_')
    p_web.SetValue('_parentrid_','')
    p_web.SetValue('_ParentProc_',p_web.formsettings.parentpage)
    p_web.AlertParent('UpdatePatrolArea')
    p_web.SetValue('_ParentProc_','')
    p_web.SetValue('_parentrid_',parentrid_)
  Else
    p_web.AlertParent('UpdatePatrolArea')
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
  of upper('PatrolAreaMap')
    do Validate::PatrolAreaMap
    loc:done = 1
  of ''
    case upper(p_web.GetValue('_calledfrom_'))
    of upper('BrowsePatrolAreaBoundary')
      do Validate::BrowsePatrolAreaBoundary  ! refreshes other fields dependent on the browse.
      do Refresh::BrowsePatrolAreaBoundary
      loc:done = 1
    end
  end
  If loc:done = 0
    p_web.PushEvent('gainfocus')
    p_web.SetValue('_parentProc_',p_web.SetParent(loc:parent,'UpdatePatrolArea'))
    p_web.SetValue('BrowsePatrolAreaBoundary:parentIs','Form')
    BrowsePatrolAreaBoundary(p_web)
    p_web.PopEvent()
  end

! ---------------------------------------------------------------------------------------------------
! This code runs before the record is loaded. For code after the record is loaded see the PreInsert, PreCopy, PreUpdate and so on
InitForm       Routine
  DATA
LF  &FILE
  CODE
  p_web.SetValue('UpdatePatrolArea_form:inited_',1)
  p_web.formsettings.file = 'PatrolArea'
  p_web.formsettings.key = 'Pat:GuidKey'
  do RestoreMem

SetFormSettings  routine
  data
  code
  If p_web.Formstate = ''
    p_web.formsettings.file = 'PatrolArea'
    p_web.formsettings.key = 'Pat:GuidKey'
      clear(p_web.formsettings.FieldName)
    p_web.formsettings.recordid[1] = Pat:Guid
    p_web.formsettings.FieldName[1] = 'Pat:Guid'
    do SetAction
    if p_web.GetSessionValue('UpdatePatrolArea:Primed') = 1 or Ans = Net:ChangeRecord
      p_web.formsettings.action = Net:ChangeRecord
    Else
      p_web.formsettings.action = Loc:Act
    End
    p_web.formsettings.OriginalAction = Loc:Act
    If p_web.GetValue('_parentPage') <> ''
      p_web.formsettings.parentpage = p_web.GetValue('_parentPage')
    else
      p_web.formsettings.parentpage = 'UpdatePatrolArea'
    end
    p_web.formsettings.proc = 'UpdatePatrolArea'
    clear(p_web.formsettings.target)
    p_web.FormState = p_web.AddSettings()
  end

CancelForm  Routine
  IF p_web.GetSessionValue('UpdatePatrolArea:Primed') = 1
    p_web.DeleteFile(PatrolArea)
    p_web.SetSessionValue('UpdatePatrolArea:Primed',0)
  End
  p_web.SetSessionValue('UpdatePatrolArea:Active',0)

SendMessage Routine
  p_web.Message('Alert',loc:alert,p_web.site.MessageClass,Net:Send,1)

SetPics  Routine
  p_web.SetValue('UpdateFile','PatrolArea')
  p_web.SetValue('UpdateKey','Pat:GuidKey')
  If p_web.IfExistsValue('Pat:Name')
    p_web.SetPicture('Pat:Name','@s20')
  End
  p_web.SetSessionPicture('Pat:Name','@s20')
  If p_web.IfExistsValue('Pat:Latitude')
    p_web.SetPicture('Pat:Latitude','@s20')
  End
  p_web.SetSessionPicture('Pat:Latitude','@s20')
  If p_web.IfExistsValue('Pat:Longitude')
    p_web.SetPicture('Pat:Longitude','@s20')
  End
  p_web.SetSessionPicture('Pat:Longitude','@s20')
  If p_web.IfExistsValue('Pat:Zoom')
    p_web.SetPicture('Pat:Zoom','@n-14')
  End
  p_web.SetSessionPicture('Pat:Zoom','@n-14')

AfterLookup Routine
  loc:TabNumber = -1
  If  true
    loc:TabNumber += 1
  End ! Tab Condition
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
    p_web.SetSessionValue('UpdatePatrolArea_CurrentAction',Net:ViewRecord)
  Else
    Case p_web.GetSessionValue('UpdatePatrolArea_CurrentAction')
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
    loc:formaction = p_web.getsessionvalue('SaveReferUpdatePatrolArea')
  End
  if p_web.GetValue('_ChainToPage_') <> ''
    loc:formaction = p_web.GetValue('_ChainToPage_')
    p_web.SetSessionValue('UpdatePatrolArea_ChainTo',loc:FormAction)
    loc:formactiontarget = '_self'
  ElsIf p_web.IfExistsSessionValue('UpdatePatrolArea_ChainTo')
    loc:formaction = p_web.GetSessionValue('UpdatePatrolArea_ChainTo')
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
  do Refresh::Pat:Name
  do Refresh::Pat:Latitude
  do Refresh::Pat:Longitude
  do Refresh::Pat:Zoom
  do Refresh::PatrolAreaMap
  do Refresh::BrowsePatrolAreaBoundary
  p_web.Script('$(''#'&clip(loc:formname)&''').find(''#FormState'').val('''&clip(p_web.FormState)&''');' & p_web.CRLF)
  p_web.ntForm(loc:formname,'show')

PopulateData  Routine

GenerateForm  Routine
  data
loc:disabled  Long
loc:pos       Long
  code
  p_web.ClearBrowse('UpdatePatrolArea')
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
      packet.append('<div id="'&  lower('Tab_UpdatePatrolArea') & '_div" class="' & p_web.combine(p_web.site.style.FormTabOuter,,' nt-tab-carousel') & '">')
    of Net:Web:TaskPanel
    of Net:Web:Wizard
      packet.append(p_web.DivHeader('Tab_UpdatePatrolArea',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    Else
      packet.append(p_web.DivHeader('Tab_UpdatePatrolArea',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    End
    Case loc:TabStyle
    of Net:Web:Tab
      packet.append('<ul class="'&p_web.combine(p_web.site.style.FormTabTitle,)&'">'& p_web.CRLF)
      If  true
        packet.append('<li><a href="#' & lower('tab_UpdatePatrolArea0_div') & '">' & '<div>' & p_web.Translate('General',true)&'</div></a></li>'& p_web.CRLF) !a
      End ! Tab Condition
      If  true
        packet.append('<li><a href="#' & lower('tab_UpdatePatrolArea1_div') & '">' & '<div>' & p_web.Translate('Patrol Area Boundary',true)&'</div></a></li>'& p_web.CRLF) !a
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
  do GenerateTab1
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
          packet.append('<div id="UpdatePatrolArea_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdatePatrolArea_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolArea')) !f1
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolArea')) !f2
        End
        loc:javascript = ''
        loc:javascript = clip(loc:javascript) & 'removeElement('''&clip(loc:formname)&''','''&lower('UpdatePatrolArea_BrowsePatrolAreaBoundary_table_div')&''');'
        packet.append(p_web.CreateStdButton('button',Net:Web:SaveButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdatePatrolArea',1)) !f3
        loc:javascript = ''
        loc:javascript = clip(loc:javascript) & 'removeElement('''&clip(loc:formname)&''','''&lower('UpdatePatrolArea_BrowsePatrolAreaBoundary_table_div')&''');'
        if loc:popup
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdatePatrolArea')) !f5
        else
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdatePatrolArea')) !f6
        end
        packet.append('</div>'  & p_web.CRLF) ! end id="UpdatePatrolArea_saveset"
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdatePatrolArea_saveset','controlgroup',loc:options)
        End
      ElsIf loc:ViewOnly = 1 and (loc:AutoSave=0 or loc:Act <> Net:ChangeRecord)
        If loc:TabStyle = Net:Web:Wizard
          packet.append('<div id="UpdatePatrolArea_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdatePatrolArea_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolArea')) !f8
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolArea')) !f9
        End
        loc:javascript = ''
        loc:javascript = clip(loc:javascript) & 'removeElement('''&clip(loc:formname)&''','''&lower('UpdatePatrolArea_BrowsePatrolAreaBoundary_table_div')&''');'
        if loc:popup
          loc:javascript = clip(loc:javascript) & 'ntd.close();'
          packet.append(p_web.CreateStdButton('button',Net:Web:CloseButton,loc:formname,,,loc:javascript,,,,'UpdatePatrolArea')) !f10
        else
          packet.append(p_web.CreateStdButton('submit',Net:Web:CloseButton,loc:formname,loc:formactioncancel,loc:formactioncanceltarget,,,,,'UpdatePatrolArea')) !f11
        end
        packet.append('</div>' & p_web.CRLF)
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdatePatrolArea_saveset','controlgroup',loc:options)
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
      p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdatePatrolArea')>0,p_web.GetSessionValue('showtab_UpdatePatrolArea'),'0'))
      p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdatePatrolArea_tabchanged'',$(this).accordion("option","active")); }')
      p_web.jQuery('#' & lower('Tab_UpdatePatrolArea') & '_div','accordion',loc:options)
    of Net:Web:TaskPanel
    of Net:Web:Tab
      p_web.SetOption(loc:options,'activate','function(event,ui){{TabChanged(''UpdatePatrolArea_tabchanged'',$(this).tabs("option","active"));}')
      p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdatePatrolArea')>0,p_web.GetSessionValue('showtab_UpdatePatrolArea'),'0'))
      p_web.jQuery('#' & lower('Tab_UpdatePatrolArea') & '_div','tabs',loc:options)
    of Net:Web:Wizard
       p_web.SetOption(loc:options,'procedure',lower('UpdatePatrolArea'))
       p_web.SetOption(loc:options,'popup',loc:popup)
  
       p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdatePatrolArea')>0,p_web.GetSessionValue('showtab_UpdatePatrolArea'),0))
       p_web.SetOption(loc:options,'ntform', '#' & clip(loc:formname))
       p_web.ntWiz('UpdatePatrolArea',loc:options)
    of Net:Web:Carousel
       p_web.SetOption(loc:options,'id',lower('tab_UpdatePatrolArea_div'))
       p_web.SetOption(loc:options,'dots','^true')
       p_web.SetOption(loc:options,'autoplay','^false')
       p_web.jQuery('#' & lower('tab_UpdatePatrolArea_div'),'slick',loc:options)
    end
    do SendPacket
  packet.append('</form>'&p_web.CRLF)
  do SendPacket
  loc:options.Free(True)
  If p_web.CanCallAddSec() = net:ok
    p_web.SetOption(loc:options,'addsec','UpdatePatrolArea')
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
    p_web.AddPreCall('UpdatePatrolArea')
    If p_web.site.FrontLoaded = 0
      p_web.SetValue('_CallPopups',1) ! do procedure and dependants
    Else
      p_web.SetValue('_CallPopups',3) ! do dependants, procedure already done
    End
    If p_web.GetPreCall('BrowsePatrolAreaBoundary') = 0
      p_web.SetValue('BrowsePatrolAreaBoundary:FormName',loc:formname)
      p_web.SetValue('BrowsePatrolAreaBoundary:parentIs','Form')
      p_web.SetValue('_parentProc_',p_web.SetParent(loc:parent,'UpdatePatrolArea'))
      BrowsePatrolAreaBoundary(p_web)
      p_web.SetValue('_CallPopups',0)
      p_web.DeleteValue('BrowsePatrolAreaBoundary:FormName')
      p_web.DeleteValue('BrowsePatrolAreaBoundary:parentIs')
      p_web.DeleteValue('_parentProc_')
    End
    p_web.SetValue('_popup_',0)
    p_web.PopEvent()
  End

ntForm Routine
  data
loc:BuildOptions                stringTheory
  code
  p_web.SetOption(loc:options,'id',clip(loc:formname))
  p_web.SetOption(loc:options,'procedure', lower('UpdatePatrolArea'))
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
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdatePatrolArea0',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea0_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate('General')&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdatePatrolArea0',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea0',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="0"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_UpdatePatrolArea0_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-tab-carousel-header',)&'">'&|
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-rounded-header ui-corner-all',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend,,,1) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset"><legend class="'&p_web.combine(' nt-plain-legend',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</legend>' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea0',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('UpdatePatrolArea_container',p_web.combine(,),,loc:LayoutMethod))
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Pat:Name_row')) ,p_web.Combine(lower(' UpdatePatrolArea-Pat:Name-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Pat:Name
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
        do Value::Pat:Name
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Pat:Name
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Pat:Latitude_row')) ,p_web.Combine(lower(' UpdatePatrolArea-Pat:Latitude-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Pat:Latitude
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
        do Value::Pat:Latitude
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Pat:Latitude
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Pat:Longitude_row')) ,p_web.Combine(lower(' UpdatePatrolArea-Pat:Longitude-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Pat:Longitude
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
        do Value::Pat:Longitude
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Pat:Longitude
          packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
          loc:cellstarted = 0
          do SendPacket
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Pat:Zoom_row')) ,p_web.Combine(lower(' UpdatePatrolArea-Pat:Zoom-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Pat:Zoom
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
        do Value::Pat:Zoom
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Pat:Zoom
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('PatrolAreaMap_row')) ,p_web.Combine(lower(' UpdatePatrolArea-PatrolAreaMap-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Value::PatrolAreaMap
          do Comment::PatrolAreaMap
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
        packet.append(p_web.FormTableEnd('UpdatePatrolArea_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('UpdatePatrolArea_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('UpdatePatrolArea_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolArea0'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdatePatrolArea')>0,p_web.GetSessionValue('showtab_UpdatePatrolArea'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdatePatrolArea_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_UpdatePatrolArea0_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolArea0'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolArea0'))
      end
      do SendPacket
  End ! TabCondition
GenerateTab1  Routine
  If  true
      Case loc:TabStyle
      of Net:Web:Accordion
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-accordion-tab-header',)&'"><div class="nt-flex">' & |
        '<div>' & p_web.Translate('Patrol Area Boundary')&'</div>' &|
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdatePatrolArea1',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea1_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate('Patrol Area Boundary')&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdatePatrolArea1',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea1',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea1',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="1"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_UpdatePatrolArea1_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-tab-carousel-header',)&'">'&|
          '<div>' & p_web.Translate('Patrol Area Boundary')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea1',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-rounded-header ui-corner-all',)&'">' & |
          '<div>' & p_web.Translate('Patrol Area Boundary')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea1',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend,,,1) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset"><legend class="'&p_web.combine(' nt-plain-legend',)&'">' & |
          '<div>' & p_web.Translate('Patrol Area Boundary')&'</div>' & |
          '</legend>' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_UpdatePatrolArea1',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('UpdatePatrolArea_container',p_web.combine(,),,loc:LayoutMethod))
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('BrowsePatrolAreaBoundary_row')) ,p_web.Combine(lower(' UpdatePatrolArea-BrowsePatrolAreaBoundary-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Value::BrowsePatrolAreaBoundary
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
        packet.append(p_web.FormTableEnd('UpdatePatrolArea_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('UpdatePatrolArea_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('UpdatePatrolArea_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolArea1'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdatePatrolArea')>0,p_web.GetSessionValue('showtab_UpdatePatrolArea'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdatePatrolArea_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_UpdatePatrolArea1_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolArea1'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdatePatrolArea1'))
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
    loc:Heading = p_web.Translate('Update Patrol Area',(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
  End
  If p_web.site.HeaderBackButton and (loc:inNetWebPopup or loc:popup)
    loc:Heading = p_web.AddHeaderBackButton(loc:Heading,,)
  End
  If loc:inNetWebPopup = 1
    exit
  end
  If loc:Heading
    If loc:popup
      p_web.SetPopupDialogHeading('UpdatePatrolArea',clip(loc:Heading),(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
    Else
      packet.append(lower('<div id="form-access-UpdatePatrolArea"></div>'))
        p_web.DivHeader('UpdatePatrolArea_header',p_web.combine(p_web.site.style.formheading,))
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

Refresh::Pat:Name  Routine
  do Prompt::Pat:Name
  do Value::Pat:Name
  do Comment::Pat:Name

Prompt::Pat:Name  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Name') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Name:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Pat:Name')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Pat:Name')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Pat:Name Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Pat:Name = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s20
    Pat:Name = p_web.DeformatValue(p_web.GetValue('Value'),'@s20')
  End
  do ValidateValue::Pat:Name  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Pat:Name   ! Field is auto-validated
  do SendMessage
  do Refresh::PatrolAreaMap  !(GenerateFieldReset)
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Pat:Name  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Pat:Name',Pat:Name).

Value::Pat:Name  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Pat:Name') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Name') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Pat:Name = p_web.RestoreValue('Pat:Name')
    do ValidateValue::Pat:Name
    If Pat:Name:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Pat:Name
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Pat:Name')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Pat:Name'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Pat:Name',p_web.GetSessionValueFormat('Pat:Name'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s20'),,'Pat:Name',,'imm',,,,'UpdatePatrolArea')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Pat:Name  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Pat:Name:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Name') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolArea_' & p_web.nocolon('Pat:Name') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Pat:Latitude  Routine
  do Prompt::Pat:Latitude
  do Value::Pat:Latitude
  do Comment::Pat:Latitude

Prompt::Pat:Latitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Latitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Latitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Pat:Latitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Pat:Latitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Pat:Latitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Pat:Latitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s20
    Pat:Latitude = p_web.DeformatValue(p_web.GetValue('Value'),'@s20')
  End
  do ValidateValue::Pat:Latitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Pat:Latitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Pat:Latitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Pat:Latitude',Pat:Latitude).

Value::Pat:Latitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Pat:Latitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Latitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Pat:Latitude = p_web.RestoreValue('Pat:Latitude')
    do ValidateValue::Pat:Latitude
    If Pat:Latitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Pat:Latitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Pat:Latitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Pat:Latitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Pat:Latitude',p_web.GetSessionValueFormat('Pat:Latitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s20'),,'Pat:Latitude',,'imm',,,,'UpdatePatrolArea')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Pat:Latitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Pat:Latitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Latitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolArea_' & p_web.nocolon('Pat:Latitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Pat:Longitude  Routine
  do Prompt::Pat:Longitude
  do Value::Pat:Longitude
  do Comment::Pat:Longitude

Prompt::Pat:Longitude  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Longitude') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Longitude:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Pat:Longitude')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Pat:Longitude')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Pat:Longitude Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Pat:Longitude = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s20
    Pat:Longitude = p_web.DeformatValue(p_web.GetValue('Value'),'@s20')
  End
  do ValidateValue::Pat:Longitude  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Pat:Longitude   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Pat:Longitude  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Pat:Longitude',Pat:Longitude).

Value::Pat:Longitude  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Pat:Longitude') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Longitude') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Pat:Longitude = p_web.RestoreValue('Pat:Longitude')
    do ValidateValue::Pat:Longitude
    If Pat:Longitude:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Pat:Longitude
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Pat:Longitude')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Pat:Longitude'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Pat:Longitude',p_web.GetSessionValueFormat('Pat:Longitude'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s20'),,'Pat:Longitude',,'imm',,,,'UpdatePatrolArea')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Pat:Longitude  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Pat:Longitude:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Longitude') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolArea_' & p_web.nocolon('Pat:Longitude') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Pat:Zoom  Routine
  do Prompt::Pat:Zoom
  do Value::Pat:Zoom
  do Comment::Pat:Zoom

Prompt::Pat:Zoom  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Zoom') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Zoom:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Pat:Zoom')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Pat:Zoom')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Pat:Zoom Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Pat:Zoom = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @n-14
    Pat:Zoom = p_web.DeformatValue(p_web.GetValue('Value'),'@n-14')
  End
  do ValidateValue::Pat:Zoom  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Pat:Zoom   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Pat:Zoom  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Pat:Zoom',Pat:Zoom).

Value::Pat:Zoom  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Pat:Zoom') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Zoom') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Pat:Zoom = p_web.RestoreValue('Pat:Zoom')
    do ValidateValue::Pat:Zoom
    If Pat:Zoom:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Pat:Zoom
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,3,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Pat:Zoom')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Pat:Zoom'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Pat:Zoom',p_web.GetSessionValueFormat('Pat:Zoom'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@n-14'),,'Pat:Zoom',,'imm',,,,'UpdatePatrolArea')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Pat:Zoom  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Pat:Zoom:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('Pat:Zoom') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolArea_' & p_web.nocolon('Pat:Zoom') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::PatrolAreaMap  Routine
  do Value::PatrolAreaMap
  do Comment::PatrolAreaMap



Validate::PatrolAreaMap Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = 
  End
  do ValidateValue::PatrolAreaMap  ! copies value to session value if valid.
  If loc:invalid = ''
    Case p_web.event
    Of 'zoomed'
      p_web.StoreValue('Pat:Zoom','_zoom_')
    Of 'clicked'
      p_web.StoreValue('Pat:Latitude','_lat_')
      p_web.StoreValue('Pat:Longitude','_lng_')
      p_web.StoreValue('Pat:Zoom','_zoom_')
    Of 'gainfocus' ! returned from form
      Case lower(p_web.GetValue('_cluster_'))
      of lower(p_web.GSV('Pat:Name'))
        p_web.SessionQueueToFile(PatrolAreaBoundary)
        p_web.GetFile(PatrolAreaBoundary,Ptb:GuidKey)
        loc:options.Free(True)
        If p_web.Site.MapDefaultMarker
          p_web.SetOption(loc:options,'icon','^' & clip(p_web.Site.MapDefaultMarker))
        End
        p_web.SetOption(loc:options,'draggable','true')
        p_web.SetOption(loc:options,'title',p_web._jsok(Ptb:Order))
        p_web.SetOption(loc:options,'opacity',25 / 100)
        Case p_web.GetValue('_action_')
        of Net:InsertRecord
        p_web.ntMap('PatrolAreaMap','addMarkerToCluster', p_web._jsok(p_web.GSV('Pat:Name')) , p_web.AddBrowseValue('UpdatePatrolArea','PatrolAreaBoundary',Ptb:GuidKey) , p_web.GetLatLng(Ptb:Latitude) , p_web.GetLatLng(Ptb:Longitude) , p_web.WrapOptions(loc:options),'',0,2)
        of Net:ChangeRecord
        p_web.ntMap('PatrolAreaMap','updateMarker', p_web.GetValue('_marker_') , p_web.GetLatLng(Ptb:Latitude) , p_web.GetLatLng(Ptb:Longitude) , p_web.WrapOptions(loc:options))
        of  Net:DeleteRecord
        p_web.ntMap('PatrolAreaMap','removeMarker', p_web.GetValue('_marker_'))
        End
      End ! Case lower(p_web.GetValue('_from_'))

    Of 'dragged'  ! marker on map was dragged
      Case lower(p_web.GetValue('_cluster_'))
      of lower(p_web.GSV('Pat:Name'))
        p_web.SessionQueueToFile(PatrolAreaBoundary)
        p_web.GetFile(PatrolAreaBoundary,Ptb:GuidKey)
        Ptb:Latitude = p_web.GetValue('_lat_')
        Ptb:Longitude = p_web.GetValue('_lng_')
        p_web.UpdateFile(PatrolAreaBoundary)
      of lower('undefined')
        p_web.StoreValue('Pat:Latitude','_lat_')
        p_web.StoreValue('Pat:Longitude','_lng_')
      End ! Case lower(p_web.GetValue('_cluster_'))
    End
  End
  p_web.PushEvent('parentupdated')
  do SendMessage
  do Refresh::Pat:Latitude  !(GenerateFieldReset)
  do Refresh::Pat:Longitude  !(GenerateFieldReset)
  do Refresh::Pat:Zoom  !(GenerateFieldReset)
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::PatrolAreaMap  Routine

Value::PatrolAreaMap  Routine
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
  If p_web.GetValue('_name_') = p_web.nocolon('PatrolAreaMap') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('PatrolAreaMap') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Map
  If loc:retrying
    do ValidateValue::PatrolAreaMap
    If PatrolAreaMap:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- MAP --- 
    loc:MapProvider = p_web.Site.MapProvider
    loc:url = ''
    packet.append(p_web.CreateMapDiv('PatrolAreaMap',,650,400)  & p_web.CRLF)
    ! Options for the leaflet.js map object
    loc:MapOptions.SetValue('')
    p_web.SetOption(loc:MapOptions,'center','['&p_web.GetLatLng(p_web.GetSessionValue('Pat:Latitude')) &',' & p_web.GetLatLng(p_web.GetSessionValue('Pat:Longitude')) &']')
    p_web.SetOption(loc:MapOptions,'zoom',p_web.SetMapZoom(loc:MapProvider,p_web.GetSessionValue('Pat:Zoom')))
    ! Options for the Scale
    loc:ScaleOptions.Free(true)
    p_web.SetOption(loc:ScaleOptions,'maxWidth',100)
    p_web.SetOption(loc:ScaleOptions,'metric',1)
    p_web.SetOption(loc:ScaleOptions,'imperial',1)
    ! options for the leaflet.js tiles layer
    p_web.SetMapDevIdOptions(loc:MapProvider,loc:TileOptions)
    ! options for the nettalk ntmap object (which takes the map and tiles options from above).
    loc:options.Free(True)
    p_web.SetOption(loc:options,'procedure','UpdatePatrolArea')
    If p_web.Site.ConnectionSecure
      p_web.SetOption(loc:options,'ssl',1)
    End
    p_web.SetOption(loc:options,'equate','PatrolAreaMap')
    p_web.SetOption(loc:options,'provider',loc:MapProvider)
    p_web.SetOption(loc:options,'divId',p_web.NoColon('PatrolAreaMap'))
    p_web.SetOption(loc:options,'tileURL',loc:url)
    p_web.SetOption(loc:options,'mapOptions',p_web.WrapOptions(loc:mapOptions))
    p_web.SetOption(loc:options,'tileOptions',p_web.WrapOptions(loc:tileOptions))
    p_web.SetOption(loc:options,'moveHomeToClick','true')
    p_web.SetOption(loc:options,'scale',1)
    p_web.SetOption(loc:options,'scaleOptions',p_web.WrapOptions(loc:scaleOptions))
    p_web.ntMap('PatrolAreaMap',loc:options)
    ! map marker at start position
    loc:options.Free(True)
    If p_web.Site.MapDefaultMarker
      p_web.SetOption(loc:options,'icon','^' & clip(p_web.Site.MapDefaultMarker))
    End
    p_web.SetOption(loc:options,'draggable','true')
    p_web.ntMap('PatrolAreaMap','addMarkerToMap','_home_', p_web.GetLatLng(Pat:Latitude) , p_web.GetLatLng(Pat:Longitude) , p_web.WrapOptions(loc:options))
  
    !--  Map Data  ---------------------------------------------------
    loc:options.Free(True)
    p_web.SetOption(loc:options,'name',p_web._jsok(p_web.GSV('Pat:Name')))
    p_web.ntMap('PatrolAreaMap','addPolygonToMap', p_web.WrapOptions(loc:options))
    PushBind()
    p_web.OpenFile(PatrolAreaBoundary)
    Bind(Ptb:Record)
    If p_web.sqlsync then p_web.SqlWait(p_web.SqlName).
    Open(PatrolAreaMap_MapDataView:1)
    loc:Filter.SetValue('')
    loc:Filter.Append(p_web.CleanFilter(PatrolAreaMap_MapDataView:1,'Ptb:PatGuid=''' & p_web.GSV('Pat:guid') & ''''))
    PatrolAreaMap_MapDataView:1{prop:filter} = p_web.AssignFilter(loc:Filter.GetValue())
    PatrolAreaMap_MapDataView:1{prop:order} = p_web.CleanFilter(PatrolAreaMap_MapDataView:1,'Ptb:Order')
    Set(PatrolAreaMap_MapDataView:1)
    Loc:counter = 0
    loc:mapdata.setvalue('')
    Loop
      next(PatrolAreaMap_MapDataView:1)
      If Errorcode() then break.
      loc:options.Free(True)
      If p_web.Site.MapDefaultMarker
        p_web.SetOption(loc:options,'icon','^' & clip(p_web.Site.MapDefaultMarker))
      End
      p_web.SetOption(loc:options,'opacity',25 / 100)
      p_web.SetOption(loc:options,'title',p_web._jsok(Ptb:Order))
      p_web.SetOption(loc:options,'draggable','true')
      loc:mapdata.append(Choose(loc:counter=0,'',',') & '["' & p_web.AddBrowseValue('UpdatePatrolArea','PatrolAreaBoundary',Ptb:GuidKey) &'",' & p_web.GetLatLng(Ptb:Latitude) & ',' & p_web.GetLatLng(Ptb:Longitude) & ', ' & p_web.WrapOptions(loc:options) & ',"'&p_web._jsok(, Net:HtmlOk*0+Net:UnsafeHtmlOk*0)&'",0,2]' & p_web.CRLF)
      loc:counter += 1
    End
    Close(PatrolAreaMap_MapDataView:1)
    If p_web.sqlsync then p_web.SqlRelease(p_web.SqlName).
    p_Web.CloseFile(PatrolAreaBoundary)
    PopBind()
    p_web.ntMap('PatrolAreaMap','addMarkersToPolygon', p_web._jsok(p_web.GSV('Pat:Name')) , '[' & loc:mapdata.GetValue() & ']')
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::PatrolAreaMap  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if PatrolAreaMap:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('PatrolAreaMap') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolArea_' & p_web.nocolon('PatrolAreaMap') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::BrowsePatrolAreaBoundary  Routine
  do Value::BrowsePatrolAreaBoundary
  do Comment::BrowsePatrolAreaBoundary



Validate::BrowsePatrolAreaBoundary Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
  Elsif true
    p_web.StoreValue('Ptb:Guid')
  End
  do ValidateValue::BrowsePatrolAreaBoundary  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::BrowsePatrolAreaBoundary  Routine
          ! BrowsePatrolAreaBoundary :: NetWebBrowse

Value::BrowsePatrolAreaBoundary  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('BrowsePatrolAreaBoundary') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 Browse
  loc:extra = ''
  p_web.SetValue('_silent_',Choose(1=0,1,0))
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- BROWSE or -- YEAR --- or -- PROCEDURE --  BrowsePatrolAreaBoundary
    do SendPacket
    p_web.SetValue('BrowsePatrolAreaBoundary:FormName',loc:formname)
    p_web.SetValue('BrowsePatrolAreaBoundary:parentIs','Form')
    p_web.SetValue('_parentProc_',p_web.SetParent(loc:parent,'UpdatePatrolArea'))
    p_web.SetValue('_viewonly_',loc:viewonly)
    if p_web.site.frontloaded
      loc:SaveCallPopups = p_web.GetValue('_CallPopups')
      if p_web.Ajax = 0
        p_web.SetValue('_CallPopups',5)
        p_web.DivHeader(lower('UpdatePatrolArea_BrowsePatrolAreaBoundary_embedded'),p_web.Combine('nt-embedded-procedure',),,,,1)
      else
        p_web.SetValue('_CallPopups',4)
      end
      BrowsePatrolAreaBoundary(p_web)
      if p_web.Ajax = 0
        p_web.DivFooter()
        p_web.DivHeader('UpdatePatrolArea_' & lower('BrowsePatrolAreaBoundary') & '_value')
        p_web.DivFooter()
      end
      p_web.SetValue('_CallPopups',loc:SaveCallPopups)
    elsif p_web.Ajax = 0
      p_web.SetSessionValue('UpdatePatrolArea:_popup_',p_web.GetValue('_popup_')) ! stores the current procedure popup state
      p_web.DivHeader(lower('UpdatePatrolArea_BrowsePatrolAreaBoundary_embedded'),p_web.Combine('nt-embedded-procedure',))
      BrowsePatrolAreaBoundary(p_web) ! form in page mode, just generate procedure here.
      p_web.DivFooter()
  
      p_web.DivHeader('UpdatePatrolArea_' & lower('BrowsePatrolAreaBoundary') & '_value')
      p_web.DivFooter()
    else ! ajax = 1, not front-loaded
      if p_web.GetValue('_popup_') = 1
        p_web.SetSessionValue('UpdatePatrolArea:_popup_',1)
      elsif p_web.GetSessionValue('UpdatePatrolArea:_popup_') = 1
        p_web.SetValue('_popup_',1)
      end
      BrowsePatrolAreaBoundary(p_web)
    end
    do SendPacket

Comment::BrowsePatrolAreaBoundary  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if BrowsePatrolAreaBoundary:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdatePatrolArea_' & p_web.nocolon('BrowsePatrolAreaBoundary') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdatePatrolArea_' & p_web.nocolon('BrowsePatrolAreaBoundary') & '_comment_div").html("'&clip(loc:comment)&'");')
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
  of lower('UpdatePatrolArea_nexttab_' & 0)
    Pat:Name = p_web.GetSessionValue('Pat:Name')
    do ValidateValue::Pat:Name
    If loc:Invalid
      loc:retrying = 1
      do Value::Pat:Name
      do Comment::Pat:Name ! allows comment style to be updated.
    End
    Pat:Latitude = p_web.GetSessionValue('Pat:Latitude')
    do ValidateValue::Pat:Latitude
    If loc:Invalid
      loc:retrying = 1
      do Value::Pat:Latitude
      do Comment::Pat:Latitude ! allows comment style to be updated.
    End
    Pat:Longitude = p_web.GetSessionValue('Pat:Longitude')
    do ValidateValue::Pat:Longitude
    If loc:Invalid
      loc:retrying = 1
      do Value::Pat:Longitude
      do Comment::Pat:Longitude ! allows comment style to be updated.
    End
    Pat:Zoom = p_web.GetSessionValue('Pat:Zoom')
    do ValidateValue::Pat:Zoom
    If loc:Invalid
      loc:retrying = 1
      do Value::Pat:Zoom
      do Comment::Pat:Zoom ! allows comment style to be updated.
    End
    If loc:Invalid then exit.
  of lower('UpdatePatrolArea_nexttab_' & 1)
    If loc:Invalid then exit.
  End
  p_web.ntWiz('UpdatePatrolArea','next')

ChangeTab  routine
  p_web.ChangeTab(loc:TabStyle,'UpdatePatrolArea',loc:TabTo)

TabChanged  routine
  data
TabNumber   Long   !! remember that tabs are numbered from 0
TabHeading  String(252),dim(2)
  code
  tabnumber = p_web.GetValue('_tab_')
  tabheading[1]  = p_web.Translate('General')
  tabheading[2]  = p_web.Translate('Patrol Area Boundary')
  p_web.SetSessionValue('showtab_UpdatePatrolArea',tabnumber) !! remember that tabs are numbered from 0

CallDiv    routine
  data
  code
  p_web.Ajax = 1
  p_web.PageName = p_web._unEscape(p_web.PageName)
  case lower(p_web.PageName)
  of lower('UpdatePatrolArea') & '_tabchanged'
     do TabChanged
  of lower('UpdatePatrolArea_tab_' & 0)
    do GenerateTab0
  of lower('UpdatePatrolArea_Pat:Name_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Pat:Name
        do AlertParent
      of 'timer'
        do refresh::Pat:Name
        do Refresh::PatrolAreaMap
        do AlertParent
      else
        do Value::Pat:Name
      end
  of lower('UpdatePatrolArea_Pat:Latitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Pat:Latitude
        do AlertParent
      of 'timer'
        do refresh::Pat:Latitude
        do AlertParent
      else
        do Value::Pat:Latitude
      end
  of lower('UpdatePatrolArea_Pat:Longitude_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Pat:Longitude
        do AlertParent
      of 'timer'
        do refresh::Pat:Longitude
        do AlertParent
      else
        do Value::Pat:Longitude
      end
  of lower('UpdatePatrolArea_Pat:Zoom_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Pat:Zoom
        do AlertParent
      of 'timer'
        do refresh::Pat:Zoom
        do AlertParent
      else
        do Value::Pat:Zoom
      end
  of lower('UpdatePatrolArea_PatrolAreaMap_value')
      case p_web.Event ! Map
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::PatrolAreaMap
        do AlertParent
      of 'zoomed'
      orof 'moved'
      orof 'dragged'
      orof 'clicked'
        do Validate::PatrolAreaMap
        do AlertParent
      of 'timer'
        do refresh::PatrolAreaMap
        do Refresh::Pat:Latitude
        do Refresh::Pat:Longitude
        do Refresh::Pat:Zoom
        do AlertParent
      else
        do Value::PatrolAreaMap
      end
  of lower('UpdatePatrolArea_tab_' & 1)
    do GenerateTab1
  of lower('UpdatePatrolArea_BrowsePatrolAreaBoundary_value')
  orof lower('UpdatePatrolArea' & net:PARENTSEPARATOR & 'BrowsePatrolAreaBoundary_value')
      case p_web.Event ! Browse
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::BrowsePatrolAreaBoundary
        do AlertParent
      of 'newselection' !EVENT:NewSelection !2
      orof 'childnewselection'
      orof 'childupdated'
        p_web.PushEvent('parentnewselection')
        p_web.PopEvent()
        do AlertParent
      of 'timer'
        do refresh::BrowsePatrolAreaBoundary
        do AlertParent
      else
        do Value::BrowsePatrolAreaBoundary
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
  p_web.SetValue('UpdatePatrolArea_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolArea:Active',1)
  p_web.SetSessionValue('UpdatePatrolArea_CurrentAction',Net:InsertRecord)
  p_web.SetSessionValue('showtab_UpdatePatrolArea',0)   !
  Clear(Pat:record) ! Primes moved before auto-increment (PrimeRecord) call.
  Pat:Guid = glo:st.Random(16,st:Upper+st:Number)            ! taken from dictionary initial value
  p_web.SetSessionValue('Pat:Guid',Pat:Guid)
  If not Pat:Latitude
    Pat:Latitude = '0'
    p_web.SetSessionValue('Pat:Latitude',Pat:Latitude)  ! taken from priming tab
  end
  If not Pat:Longitude
    Pat:Longitude = '0'
    p_web.SetSessionValue('Pat:Longitude',Pat:Longitude)  ! taken from priming tab
  end
  Pat:Zoom = 14
  p_web.SetSessionValue('Pat:Zoom',Pat:Zoom)    ! taken from priming tab
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreCopy  Routine
  data
  code
  p_web.SetValue('UpdatePatrolArea_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolArea:Active',1)
  p_web.SetSessionValue('UpdatePatrolArea_CurrentAction',Net:CopyRecord)
  p_web.SetSessionValue('showtab_UpdatePatrolArea',0)  !
  p_web._PreCopyRecord(PatrolArea,Pat:GuidKey)
  Pat:Guid = glo:st.Random(16,st:Upper+st:Number)
  p_web.SetSessionValue('Pat:Guid',Pat:Guid)
  ! here we need to copy the non-unique fields across
  If not Pat:Latitude
    Pat:Latitude = '0'
    p_web.SetSessionValue('Pat:Latitude',Pat:Latitude)
  end
  If not Pat:Longitude
    Pat:Longitude = '0'
    p_web.SetSessionValue('Pat:Longitude',Pat:Longitude)
  end
  Pat:Zoom = 14
  p_web.SetSessionValue('Pat:Zoom',Pat:Zoom)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
! this code runs After the record is loaded. To run code before, see InitForm Routine
PreUpdate  Routine
  data
loc:offset      Long
  code
  p_web.SetValue('UpdatePatrolArea_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolArea:Active',1)
  p_web.SetSessionValue('UpdatePatrolArea_CurrentAction',Net:ChangeRecord)
  p_web.SetSessionValue('UpdatePatrolArea:Primed',0)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreDelete       Routine
  data
  code
  p_web.SetValue('UpdatePatrolArea_form:ready_',1)
  p_web.SetSessionValue('UpdatePatrolArea_CurrentAction',Net:DeleteRecord)
  p_web.SetSessionValue('UpdatePatrolArea:Primed',0)
  p_web.SetSessionValue('showtab_UpdatePatrolArea',0)   !
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
LoadRelatedRecords  Routine
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
          If p_web.IfExistsValue('Pat:Name')
            Pat:Name = p_web.GetValue('Pat:Name')
          End
          If p_web.IfExistsValue('Pat:Latitude')
            Pat:Latitude = p_web.GetValue('Pat:Latitude')
          End
          If p_web.IfExistsValue('Pat:Longitude')
            Pat:Longitude = p_web.GetValue('Pat:Longitude')
          End
          If p_web.IfExistsValue('Pat:Zoom')
            Pat:Zoom = p_web.GetValue('Pat:Zoom')
          End
  End   !tab condition
    If  true
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
  If p_web.GetSessionValue('UpdatePatrolArea:Primed') = 0 and Ans = Net:InsertRecord
    Get(PatrolArea,0)
    GotFileZero = true
  End
  ! Check for duplicates
  If Duplicate(Pat:GuidKey) ! In SQL drivers this clears the Blob field, if Get(file,0) was done. TPS does not.
    loc:Invalid = 'Pat:Guid'
    if not loc:alert then loc:Alert = clip(p_web.site.DuplicateText) & ' GuidKey --> Pat:Guid = ' & clip(Pat:Guid).
  End
  If Duplicate(Pat:NameKey) ! In SQL drivers this clears the Blob field, if Get(file,0) was done. TPS does not.
    loc:Invalid = 'Pat:Name'
    if not loc:alert then loc:Alert = clip(p_web.site.DuplicateText) & ' NameKey --> ' & clip('Name')&' = ' & clip(Pat:Name).
  End
  If GotFileZero
  End

ValidateDelete  Routine
  p_web.DeleteSessionValue('UpdatePatrolArea_ChainTo')
  ! Check for restricted child records

ValidateRecord  Routine
  p_web.DeleteSessionValue('UpdatePatrolArea_ChainTo')

  ! Then add additional constraints set on the template
  loc:InvalidTab = -1
  ! tab = 1
    If  true
        loc:InvalidTab += 1
        do ValidateValue::Pat:Name
        If loc:Invalid then exit.
        do ValidateValue::Pat:Latitude
        If loc:Invalid then exit.
        do ValidateValue::Pat:Longitude
        If loc:Invalid then exit.
        do ValidateValue::Pat:Zoom
        If loc:Invalid then exit.
        do ValidateValue::PatrolAreaMap
        If loc:Invalid then exit.
  End ! Tab Condition
  ! tab = 2
    If  true
        loc:InvalidTab += 1
        do ValidateValue::BrowsePatrolAreaBoundary
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
    p_web.InsertAgain('UpdatePatrolArea')
    Clear(Pat:Record)
  Else
    p_web.SetSessionValue('UpdatePatrolArea:Active',0)
  End
PostCopy        Routine
  Data
  Code
  p_web.SetSessionValue('UpdatePatrolArea:Primed',0)
  p_web.SetSessionValue('UpdatePatrolArea:Active',0)

PostUpdate      Routine
  Data
  Code
  p_web.SetSessionValue('UpdatePatrolArea:Primed',0)
  p_web.SetSessionValue('UpdatePatrolArea:Active',0)

PostDelete      Routine
