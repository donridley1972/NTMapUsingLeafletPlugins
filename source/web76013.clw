

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76013.INC'),ONCE        !Local module procedure declarations
                     END


UpdateDistrict       PROCEDURE  (NetWebServerWorker p_web,long p_stage=0)
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
District::State  USHORT
Dis:Name:IsInvalid  Long
Dis:Description:IsInvalid  Long
Dis:Border:IsInvalid  Long
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
  loc:procedure = lower('UpdateDistrict')
  GlobalErrors.SetProcedureName('UpdateDistrict')
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
  loc:formname = lower('UpdateDistrict_frm')
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
      if p_web.Event = 'parentnewselection' or  p_web.GetValue('UpdateDistrict:parentIs') = 'Browse' ! allow for form used as a child of a browse, default to change mode.
        p_web.FormReady('UpdateDistrict','Change','Dis:Guid',p_web.GetSessionValue('Dis:Guid'))
      Else
        p_web.FormReady('UpdateDistrict','')
      End
    End
    if p_web.site.frontloaded and p_web.Ajax and loc:popup = 1
      loc:FrontLoading = net:GeneratingData
    else
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdateDistrict')
        p_web.DivHeader(p_web.site.ContentBody,p_web.site.contentbodydivclass)
      End
      p_web.DivHeader('UpdateDistrict',p_web.combine(p_web.site.style.formdiv,))
      p_web.DivHeader('UpdateDistrict_alert',p_web.combine(p_web.site.MessageClass,' nt-hidden'))
      p_web.DivFooter()
    End
    do SetPics
    if loc:FrontLoading = net:GeneratingData
      do GenerateData
    else
      do GenerateForm
      p_web.DivFooter()
      If p_web.site.ContentBody <> '' and lower(p_web.GetValue('_cb_')) = lower('UpdateDistrict')
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
    loc:poppedup = p_web.GetValue('_UpdateDistrict:_poppedup_')
    if p_web.site.FrontLoaded then loc:popup = 1.
    if loc:poppedup = 0 and p_Web.Ajax = 0
      If p_web.GetPreCall('UpdateDistrict') = 0 and (p_web.GetValue('_CallPopups') = 0 or p_web.GetValue('_CallPopups') = 1)
        p_web.AddPreCall('UpdateDistrict')
        p_web.DivHeader('popup_UpdateDistrict','nt-hidden',,,,1,,,'popup_UpdateDistrict')
        p_web.DivHeader('UpdateDistrict',p_web.combine(p_web.site.style.formdiv,),,,,1)
        If p_web.site.FrontLoaded
          loc:frontloading = net:GeneratingPage
          do GenerateForm
        End
        p_web.DivFooter()
        p_web.DivFooter(,lower('popup_UpdateDistrict End'))
        do Heading
        loc:options.Free(True)
        p_web.SetOption(loc:options,'close','function(event, ui) {{ ntd.pop(); }')
        p_web.SetOption(loc:options,'autoOpen','false')
        p_web.SetOption(loc:options,'width',900)
        p_web.SetOption(loc:options,'modal','true')
        p_web.SetOption(loc:options,'title',loc:Heading)
        p_web.SetOption(loc:options,'position','{{ my: "top", at: "top+' & clip(15) & '", of: window }')
        If p_web.CanCallAddSec() = net:ok
          p_web.SetOption(loc:options,'addsec','UpdateDistrict')
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
        p_web.jQuery('#' & lower('popup_UpdateDistrict_div'),'dialog',loc:options,'.removeClass("nt-hidden")')
      End
      do popups ! includes all the other popups dependant on this procedure
      loc:poppedup = 1
      p_web.SetValue('_UpdateDistrict:_poppedup_',1)
    end

  of Net:Web:AfterLookup + Net:Web:Cancel
    loc:LookupDone = 0
    do AfterLookup
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdateDistrict')&'_div'').dialog(''close'');')
    end

  of Net:Web:AfterLookup
    loc:LookupDone = 1
    do AfterLookup

  of Net:Web:Cancel
    do CancelForm
    if p_web.Ajax = 1 and loc:popup
      p_web.script('$(''#popup_'&lower('UpdateDistrict')&'_div'').dialog(''close'');')
    end

  of Net:InsertRecord + NET:WEB:StagePre
    if p_web._InsertAfterSave = 0
      p_web.setsessionvalue('SaveReferUpdateDistrict',p_web.getPageName(p_web.RequestReferer))
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
    p_web.setsessionvalue('SaveReferUpdateDistrict',p_web.getPageName(p_web.RequestReferer))
    do PreCopy
  of Net:CopyRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateCopy
  of Net:CopyRecord + NET:WEB:StagePost
    do RestoreMem
    do PostWrite
    do PostCopy
  of Net:CopyRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Dis:Guid') = 0 then p_web.SetValue('Dis:Guid',p_web.GetSessionValue('Dis:Guid')).
    do PreCopy
  of Net:ChangeRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdateDistrict',p_web.getPageName(p_web.RequestReferer))      !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateDistrict',0)           !
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
    If p_web.IfExistsValue('Dis:Guid') = 0 then p_web.SetValue('Dis:Guid',p_web.GetSessionValue('Dis:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateDistrict',0)     !
  of Net:DeleteRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdateDistrict',p_web.getPageName(p_web.RequestReferer))   !
    do PreDelete
  of Net:DeleteRecord + NET:WEB:StageValidate
    do RestoreMem
    do ValidateDelete
  of Net:DeleteRecord + NET:WEB:StagePost
    do RestoreMem
    do PostDelete
  of Net:ViewRecord + NET:WEB:Populate
    If p_web.IfExistsValue('Dis:Guid') = 0 then p_web.SetValue('Dis:Guid',p_web.GetSessionValue('Dis:Guid')).
    do OpenFiles
    do InitForm
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateDistrict',0)  !

  of Net:ViewRecord + NET:WEB:StagePre
    p_web.SetSessionValue('SaveReferUpdateDistrict',p_web.getPageName(p_web.RequestReferer))   !
    do PreUpdate
    p_web.SetSessionValue('showtab_UpdateDistrict',0)    !
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
    p_web.SetSessionValue('showtab_UpdateDistrict',Loc:InvalidTab)   !
  ElsIf band(p_stage,NET:WEB:StageValidate) > 0 and band(p_stage,Net:DeleteRecord) <> Net:DeleteRecord and band(p_stage,Net:WriteMask) > 0 and p_web.Ajax = 1 and loc:popup
    If p_web.IfExistsValue('_stayopen_')
    ! only a partial save, so don't complete the form.
    ElsIf loc:FormOnSave = Net:InsertAgain
      If band(loc:act,Net:InsertRecord) <> Net:InsertRecord
        p_web.script('$(''#popup_'&lower('UpdateDistrict')&'_div'').dialog(''close'');')
      End
    Else
      p_web.script('$(''#popup_'&lower('UpdateDistrict')&'_div'').dialog(''close'');')
    End
  End
  If loc:alert <> ''             !
    p_web.SetAlert(loc:alert, net:Alert + Net:Message,'UpdateDistrict',1)
  End                            !
  do CloseFiles
  GlobalErrors.SetProcedureName()
  return Ans

OpenFiles  ROUTINE
  FilesErrorOnOpen.SetValue('')
  If p_web.OpenFile(District) <> 0
    FilesErrorOnOpen.Append('District',st:clip,',')
  End
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened
  p_Web.CloseFile(District)
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
    p_web.AlertParent('UpdateDistrict')
  Elsif p_web.formsettings.parentpage
    parentrid_ = p_web.GetValue('_parentrid_')
    p_web.SetValue('_parentrid_','')
    p_web.SetValue('_ParentProc_',p_web.formsettings.parentpage)
    p_web.AlertParent('UpdateDistrict')
    p_web.SetValue('_ParentProc_','')
    p_web.SetValue('_parentrid_',parentrid_)
  Else
    p_web.AlertParent('UpdateDistrict')
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
  p_web.SetValue('UpdateDistrict_form:inited_',1)
  p_web.formsettings.file = 'District'
  p_web.formsettings.key = 'Dis:GuidKey'
  do RestoreMem

SetFormSettings  routine
  data
  code
  If p_web.Formstate = ''
    p_web.formsettings.file = 'District'
    p_web.formsettings.key = 'Dis:GuidKey'
      clear(p_web.formsettings.FieldName)
    p_web.formsettings.recordid[1] = Dis:Guid
    p_web.formsettings.FieldName[1] = 'Dis:Guid'
    do SetAction
    if p_web.GetSessionValue('UpdateDistrict:Primed') = 1 or Ans = Net:ChangeRecord
      p_web.formsettings.action = Net:ChangeRecord
    Else
      p_web.formsettings.action = Loc:Act
    End
    p_web.formsettings.OriginalAction = Loc:Act
    If p_web.GetValue('_parentPage') <> ''
      p_web.formsettings.parentpage = p_web.GetValue('_parentPage')
    else
      p_web.formsettings.parentpage = 'UpdateDistrict'
    end
    p_web.formsettings.proc = 'UpdateDistrict'
    clear(p_web.formsettings.target)
    p_web.FormState = p_web.AddSettings()
  end

CancelForm  Routine
  IF p_web.GetSessionValue('UpdateDistrict:Primed') = 1
    p_web.DeleteFile(District)
    p_web.SetSessionValue('UpdateDistrict:Primed',0)
  End
  p_web.SetSessionValue('UpdateDistrict:Active',0)

SendMessage Routine
  p_web.Message('Alert',loc:alert,p_web.site.MessageClass,Net:Send,1)

SetPics  Routine
  p_web.SetValue('UpdateFile','District')
  p_web.SetValue('UpdateKey','Dis:GuidKey')
  If p_web.IfExistsValue('Dis:Name')
    p_web.SetPicture('Dis:Name','@s20')
  End
  p_web.SetSessionPicture('Dis:Name','@s20')
  If p_web.IfExistsValue('Dis:Description')
    p_web.SetPicture('Dis:Description','@s255')
  End
  p_web.SetSessionPicture('Dis:Description','@s255')

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
    p_web.SetSessionValue('UpdateDistrict_CurrentAction',Net:ViewRecord)
  Else
    Case p_web.GetSessionValue('UpdateDistrict_CurrentAction')
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
    loc:formaction = p_web.getsessionvalue('SaveReferUpdateDistrict')
  End
  if p_web.GetValue('_ChainToPage_') <> ''
    loc:formaction = p_web.GetValue('_ChainToPage_')
    p_web.SetSessionValue('UpdateDistrict_ChainTo',loc:FormAction)
    loc:formactiontarget = '_self'
  ElsIf p_web.IfExistsSessionValue('UpdateDistrict_ChainTo')
    loc:formaction = p_web.GetSessionValue('UpdateDistrict_ChainTo')
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
  do Refresh::Dis:Name
  do Refresh::Dis:Description
  do Refresh::Dis:Border
  p_web.Script('$(''#'&clip(loc:formname)&''').find(''#FormState'').val('''&clip(p_web.FormState)&''');' & p_web.CRLF)
  p_web.ntForm(loc:formname,'show')

PopulateData  Routine

GenerateForm  Routine
  data
loc:disabled  Long
loc:pos       Long
  code
  p_web.ClearBrowse('UpdateDistrict')
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
      packet.append('<div id="'&  lower('Tab_UpdateDistrict') & '_div" class="' & p_web.combine(p_web.site.style.FormTabOuter,,' nt-tab-carousel') & '">')
    of Net:Web:TaskPanel
    of Net:Web:Wizard
      packet.append(p_web.DivHeader('Tab_UpdateDistrict',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    Else
      packet.append(p_web.DivHeader('Tab_UpdateDistrict',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
    End
    Case loc:TabStyle
    of Net:Web:Tab
      packet.append('<ul class="'&p_web.combine(p_web.site.style.FormTabTitle,)&'">'& p_web.CRLF)
      If  true
        packet.append('<li><a href="#' & lower('tab_UpdateDistrict0_div') & '">' & '<div>' & p_web.Translate('General',true)&'</div></a></li>'& p_web.CRLF) !a
      End ! Tab Condition
      If  true
        packet.append('<li><a href="#' & lower('tab_UpdateDistrict1_div') & '">' & '<div>' & p_web.Translate('Intermediate',true)&'</div></a></li>'& p_web.CRLF) !a
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
          packet.append('<div id="UpdateDistrict_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdateDistrict_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdateDistrict')) !f1
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdateDistrict')) !f2
        End
        loc:javascript = ''
        packet.append(p_web.CreateStdButton('button',Net:Web:SaveButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdateDistrict',1)) !f3
        loc:javascript = ''
        if loc:popup
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdateDistrict')) !f5
        else
          packet.append(p_web.CreateStdButton('button',Net:Web:CancelButton,loc:formname,,,loc:javascript,,loc:disabled,,'UpdateDistrict')) !f6
        end
        packet.append('</div>'  & p_web.CRLF) ! end id="UpdateDistrict_saveset"
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdateDistrict_saveset','controlgroup',loc:options)
        End
      ElsIf loc:ViewOnly = 1 and (loc:AutoSave=0 or loc:Act <> Net:ChangeRecord)
        If loc:TabStyle = Net:Web:Wizard
          packet.append('<div id="UpdateDistrict_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,' nt-wizard-buttonset',)&'">')
        Else
          packet.append('<div id="UpdateDistrict_saveset" class="'&p_web.combine(p_web.site.style.FormSaveButtonSet,)&'">')
        END
        If loc:TabStyle = Net:Web:Wizard
          loc:javascript = ''
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizPreviousButton,loc:formname,,,loc:javascript,,,,'UpdateDistrict')) !f8
          packet.append(p_web.CreateStdButton('button',NET:WEB:WizNextButton,loc:formname,,,loc:javascript,,,,'UpdateDistrict')) !f9
        End
        loc:javascript = ''
        if loc:popup
          loc:javascript = clip(loc:javascript) & 'ntd.close();'
          packet.append(p_web.CreateStdButton('button',Net:Web:CloseButton,loc:formname,,,loc:javascript,,,,'UpdateDistrict')) !f10
        else
          packet.append(p_web.CreateStdButton('submit',Net:Web:CloseButton,loc:formname,loc:formactioncancel,loc:formactioncanceltarget,,,,,'UpdateDistrict')) !f11
        end
        packet.append('</div>' & p_web.CRLF)
        If p_web.site.UseSaveButtonSet
          loc:options.Free(True)
          p_web.jQuery('#' & 'UpdateDistrict_saveset','controlgroup',loc:options)
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
      p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdateDistrict')>0,p_web.GetSessionValue('showtab_UpdateDistrict'),'0'))
      p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdateDistrict_tabchanged'',$(this).accordion("option","active")); }')
      p_web.jQuery('#' & lower('Tab_UpdateDistrict') & '_div','accordion',loc:options)
    of Net:Web:TaskPanel
    of Net:Web:Tab
      p_web.SetOption(loc:options,'activate','function(event,ui){{TabChanged(''UpdateDistrict_tabchanged'',$(this).tabs("option","active"));}')
      p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdateDistrict')>0,p_web.GetSessionValue('showtab_UpdateDistrict'),'0'))
      p_web.jQuery('#' & lower('Tab_UpdateDistrict') & '_div','tabs',loc:options)
    of Net:Web:Wizard
       p_web.SetOption(loc:options,'procedure',lower('UpdateDistrict'))
       p_web.SetOption(loc:options,'popup',loc:popup)
  
       p_web.SetOption(loc:options,'active',choose(p_web.GetSessionValue('showtab_UpdateDistrict')>0,p_web.GetSessionValue('showtab_UpdateDistrict'),0))
       p_web.SetOption(loc:options,'ntform', '#' & clip(loc:formname))
       p_web.ntWiz('UpdateDistrict',loc:options)
    of Net:Web:Carousel
       p_web.SetOption(loc:options,'id',lower('tab_UpdateDistrict_div'))
       p_web.SetOption(loc:options,'dots','^true')
       p_web.SetOption(loc:options,'autoplay','^false')
       p_web.jQuery('#' & lower('tab_UpdateDistrict_div'),'slick',loc:options)
    end
    do SendPacket
  packet.append('</form>'&p_web.CRLF)
  do SendPacket
  loc:options.Free(True)
  If p_web.CanCallAddSec() = net:ok
    p_web.SetOption(loc:options,'addsec','UpdateDistrict')
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
    p_web.AddPreCall('UpdateDistrict')
    p_web.SetValue('_popup_',0)
    p_web.PopEvent()
  End

ntForm Routine
  data
loc:BuildOptions                stringTheory
  code
  p_web.SetOption(loc:options,'id',clip(loc:formname))
  p_web.SetOption(loc:options,'procedure', lower('UpdateDistrict'))
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
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdateDistrict0',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_UpdateDistrict0_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate('General')&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdateDistrict0',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_UpdateDistrict0',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_UpdateDistrict0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="0"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_UpdateDistrict0_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-tab-carousel-header',)&'">'&|
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_UpdateDistrict0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-rounded-header ui-corner-all',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_UpdateDistrict0',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend,,,1) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset"><legend class="'&p_web.combine(' nt-plain-legend',)&'">' & |
          '<div>' & p_web.Translate('General')&'</div>' & |
          '</legend>' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_UpdateDistrict0',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('UpdateDistrict_container',p_web.combine(,),,loc:LayoutMethod))
      do SendPacket
        if loc:rowstarted = 0
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Dis:Name_row')) ,p_web.Combine(lower(' UpdateDistrict-Dis:Name-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Dis:Name
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
        do Value::Dis:Name
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Dis:Name
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Dis:Description_row')) ,p_web.Combine(lower(' UpdateDistrict-Dis:Description-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Dis:Description
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
        do Value::Dis:Description
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Dis:Description
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
          packet.append(p_web.FormTableRowStart( p_web.NoColon(lower('Dis:Border_row')) ,p_web.Combine(lower(' UpdateDistrict-Dis:Border-row'),,), , , ,, loc:LayoutMethod)) !j1
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
        do Prompt::Dis:Border
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
        do Value::Dis:Border
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        loc:cellstarted = 0
          loc:width = ''
          packet.append(p_web.FormTableCellStart( , , , ,, , clip(loc:width) , loc:LayoutMethod, net:CellTypeComment))
          loc:columncounter += 1
          do SendPacket
          do Comment::Dis:Border
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
        packet.append(p_web.FormTableEnd('UpdateDistrict_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('UpdateDistrict_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('UpdateDistrict_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_UpdateDistrict0'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdateDistrict')>0,p_web.GetSessionValue('showtab_UpdateDistrict'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdateDistrict_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_UpdateDistrict0_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdateDistrict0'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdateDistrict0'))
      end
      do SendPacket
  End ! TabCondition
GenerateTab1  Routine
  If  true
      Case loc:TabStyle
      of Net:Web:Accordion
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-accordion-tab-header',)&'"><div class="nt-flex">' & |
        '<div>' & p_web.Translate('Intermediate')&'</div>' &|
        '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdateDistrict1',p_web.combine(p_web.site.style.FormTabInner,' ui-accordion-tab-content',,),Net:NoSend,,,1))
      of Net:Web:TaskPanel
        packet.append(p_web.DivHeader('tab_UpdateDistrict1_taskpanel',p_web.combine(p_web.site.style.FormTabOuter,),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' ui-taskpanel-tab-header',,)&'"><div class="nt-flex">' & |
          '<div>'&p_web.Translate('Intermediate')&'</div>' & |
          '</div></h3>' & p_web.CRLF & p_web.DivHeader('tab_UpdateDistrict1',p_web.combine(p_web.site.style.FormTabInner,' ui-taskpanel-tab-content',,),Net:NoSend,,,1))
      of Net:Web:Tab
        packet.append(p_web.DivHeader('tab_UpdateDistrict1',p_web.combine(p_web.site.style.FormTabInner,' ui-tabs-content',,),Net:NoSend,,,1))
      of Net:Web:Wizard
        packet.append(p_web.DivHeader('tab_UpdateDistrict1',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-wizard',,),Net:NoSend,,'data-tabid="1"',1))
      of Net:Web:Carousel
        packet.append('<div id="tab_UpdateDistrict1_div" class="' & p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-carousel',,) & '">')
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-tab-carousel-header',)&'">'&|
          '<div>' & p_web.Translate('Intermediate')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Rounded
        packet.append(p_web.DivHeader('tab_UpdateDistrict1',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-rounded',,),Net:NoSend,,,1))
        packet.append('<h3 class="'&p_web.combine(p_web.site.style.FormTabTitle,' nt-rounded-header ui-corner-all',)&'">' & |
          '<div>' & p_web.Translate('Intermediate')&'</div>' & |
          '</h3>' & p_web.CRLF)
      of Net:Web:Plain
        packet.append(p_web.DivHeader('tab_UpdateDistrict1',p_web.combine(clip(p_web.site.style.FormTabInner) & ' nt-plain',,),Net:NoSend,,,1) & '<fieldset class="ui-tabs ui-widget ui-widget-content ui-corner-all plain nt-plain-fieldset"><legend class="'&p_web.combine(' nt-plain-legend',)&'">' & |
          '<div>' & p_web.Translate('Intermediate')&'</div>' & |
          '</legend>' & p_web.CRLF)
      of Net:Web:None
        packet.append(p_web.DivHeader('tab_UpdateDistrict1',p_web.combine(p_web.site.style.FormTabInner,,),Net:NoSend,,,1))
      end
      do SendPacket
      packet.append(p_web.FormTableStart('UpdateDistrict_container',p_web.combine(,),,loc:LayoutMethod))
      do SendPacket
      if loc:rowstarted and loc:cellstarted
        packet.append(p_web.FormTableCellEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('UpdateDistrict_container',loc:LayoutMethod))
        loc:cellstarted = 0
        loc:rowstarted = 0
      elsif loc:rowstarted
        packet.append(p_web.FormTableRowEnd( ,loc:LayoutMethod))
        packet.append(p_web.FormTableEnd('UpdateDistrict_container',loc:LayoutMethod))
        loc:rowstarted = 0
      else
        packet.append(p_web.FormTableEnd('UpdateDistrict_container',loc:LayoutMethod))
      end
      do SendPacket
      Case loc:TabStyle
      of Net:Web:Plain
        packet.append('</fieldset>' & p_web.DivFooter(Net:NoSend,'tab_UpdateDistrict1'))
      of Net:Web:Carousel
        packet.append('</div><13,10>')
      of Net:Web:TaskPanel
        packet.append(p_web.DivFooter(Net:NoSend))
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','^true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'active', choose(p_web.GetSessionValue('showtab_UpdateDistrict')>0,p_web.GetSessionValue('showtab_UpdateDistrict'),'0'))
        p_web.SetOption(loc:options,'activate', 'function(event, ui) {{ TabChanged(''UpdateDistrict_tabchanged'',$(this).accordion("option","active")); }')
        p_web.jQuery('#' & lower('tab_UpdateDistrict1_taskpanel') & '_div','accordion',loc:options)
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdateDistrict1'))
      else
        packet.append(p_web.DivFooter(Net:NoSend,'tab_UpdateDistrict1'))
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
    loc:Heading = p_web.Translate('Update District',(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
  End
  If p_web.site.HeaderBackButton and (loc:inNetWebPopup or loc:popup)
    loc:Heading = p_web.AddHeaderBackButton(loc:Heading,,)
  End
  If loc:inNetWebPopup = 1
    exit
  end
  If loc:Heading
    If loc:popup
      p_web.SetPopupDialogHeading('UpdateDistrict',clip(loc:Heading),(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0))
    Else
      packet.append(lower('<div id="form-access-UpdateDistrict"></div>'))
        p_web.DivHeader('UpdateDistrict_header',p_web.combine(p_web.site.style.formheading,))
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

Refresh::Dis:Name  Routine
  do Prompt::Dis:Name
  do Value::Dis:Name
  do Comment::Dis:Name

Prompt::Dis:Name  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Name') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Name:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Dis:Name')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Dis:Name')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Dis:Name Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Dis:Name = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s20
    Dis:Name = p_web.DeformatValue(p_web.GetValue('Value'),'@s20')
  End
  do ValidateValue::Dis:Name  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Dis:Name   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Dis:Name  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Dis:Name',Dis:Name).

Value::Dis:Name  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Dis:Name') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Name') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Dis:Name = p_web.RestoreValue('Dis:Name')
    do ValidateValue::Dis:Name
    If Dis:Name:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Dis:Name
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Dis:Name')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Dis:Name'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Dis:Name',p_web.GetSessionValueFormat('Dis:Name'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s20'),,'Dis:Name',,'imm',,,,'UpdateDistrict')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Dis:Name  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Dis:Name:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Name') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateDistrict_' & p_web.nocolon('Dis:Name') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Dis:Description  Routine
  do Prompt::Dis:Description
  do Value::Dis:Description
  do Comment::Dis:Description

Prompt::Dis:Description  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Description') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Description:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Dis:Description')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Dis:Description')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Dis:Description Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Dis:Description = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s255
    Dis:Description = p_web.DeformatValue(p_web.GetValue('Value'),'@s255')
  End
  do ValidateValue::Dis:Description  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Dis:Description   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Dis:Description  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Dis:Description',Dis:Description).

Value::Dis:Description  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
loc:Filter       StringTheory
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Dis:Description') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Description') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  loc:fieldclass = p_web.combine(p_web.site.style.formentry,,) !t2 String
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Dis:Description = p_web.RestoreValue('Dis:Description')
    do ValidateValue::Dis:Description
    If Dis:Description:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- STRING --- Dis:Description
    loc:AutoComplete = 'autocomplete="off"'
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    loc:javascript = ''  ! MakeFormJavaScript
    if p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Dis:Description')&''').val('''&p_web._jsok(p_web.GetSessionValueFormat('Dis:Description'))&''');')
    Else
      packet.append(p_web.CreateInput('text','Dis:Description',p_web.GetSessionValueFormat('Dis:Description'),loc:fieldclass,loc:readonly,clip(loc:extra) & ' ' & clip(loc:autocomplete),,loc:javascript,p_web.PicLength('@s255'),,'Dis:Description',,'imm',,,,'UpdateDistrict')  & p_web.CRLF) !b
    End
    do SendPacket
  End
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Dis:Description  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Dis:Description:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Description') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateDistrict_' & p_web.nocolon('Dis:Description') & '_comment_div").html("'&clip(loc:comment)&'");')
  Else
    packet.append(clip(loc:comment) & p_web.DivFooter(net:nosend,,,0))
  End
  do SendPacket

Refresh::Dis:Border  Routine
  do Prompt::Dis:Border
  do Value::Dis:Border
  do Comment::Dis:Border

Prompt::Dis:Border  Routine
  loc:fieldclass = Choose(not(1=0),p_web.combine(p_web.site.style.formprompt,,),'nt-hidden')
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  Else
    packet.append(p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Border') & '_prompt',loc:fieldClass,Net:NoSend))
  End
  loc:prompt = Choose(1=0,'',p_web.Translate('Border:'))
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.Script('$(''[for="'&p_web.nocolon('Dis:Border')&'"]'').html("'&clip(loc:prompt)&'");')
  Else ! not front loaded
      packet.append('<label for="'&p_web.nocolon('Dis:Border')&'">' & clip(loc:prompt) & '</label>')
    packet.append(p_web.DivFooter(Net:NoSend,,,0))
    do SendPacket
  End  ! front loaded


Validate::Dis:Border Routine
  If p_web.Ajax = 1 and p_web.ifExistsValue('NewValue')
    Dis:Border = p_web.GetValue('NewValue')
  ElsIf p_web.IfExistsValue('Value') !FormFieldPicture =   !FieldPicture = @s255
    Dis:Border = p_web.GetValue('Value')
  End
  do ValidateValue::Dis:Border  ! copies value to session value if valid.
  p_web.PushEvent('parentupdated')
  do Refresh::Dis:Border   ! Field is auto-validated
  do SendMessage
  p_web.ntForm(loc:formname,'ready')
  p_web.PopEvent()

ValidateValue::Dis:Border  Routine
          If loc:invalid = '' then p_web.SetSessionValue('Dis:Border',Dis:Border).

Value::Dis:Border  Routine
  data
loc:fieldclass     string(StyleStringSize)
loc:extra          string(ExtraStringSize)
loc:disabled       long
loc:saveCallPopups long
loc:counter        long
  code
  If p_web.GetValue('_name_') = p_web.nocolon('Dis:Border') and p_web.GetValue('_dontrefreshvalue_') = 1 then exit.
  loc:fieldclass = p_web.Combine(p_web.site.style.formentrydiv,,)
  loc:fieldclass = choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    loc:fieldclass = 'nt-form-last-in-cell ' & loc:fieldclass
    p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Border') & '_value',loc:fieldclass)
  End
  loc:fieldclass = ''
  if p_web.site.HTMLEditor <> net:HTMLAce
    loc:fieldclass = p_web.combine(p_web.site.style.formentry,p_web.site.style.formtext,,) !t4 Text
  End
  If loc:viewonly
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryReadOnly,)
  End
  If loc:retrying
    Dis:Border = p_web.RestoreValue('Dis:Border')
    do ValidateValue::Dis:Border
    If Dis:Border:IsInvalid then loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.combine(p_web.site.style.formEntryError,).
  End
  loc:extra = ''
  If Not (1=0)  ! SecFieldHideStateRtn
    p_web.site.HTMLEditor = p_web.site.DefaultHTMLEditor
    ! --- TEXT --- Dis:Border
    loc:javascript = ''  ! MakeFormJavaScript
    loc:readonly = Choose(loc:viewonly,'readonly','')
      loc:extra = p_web.SetEntryWidth(loc:extra,,Net:Form)
    If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
      p_web.Script('$(''#'&p_web.nocolon('Dis:Border')&''').val('''&p_web._jsok(p_web.GetSessionValue('Dis:Border'))&''');')
    Else
      do SendPacket
      p_web.CreateTextArea('Dis:Border',p_web.GetSessionValue('Dis:Border'),5,60,loc:fieldclass,loc:readonly,loc:extra,loc:javascript,size(Dis:Border),,(Net:HtmlOk*0)+(Net:UnsafeHtmlOk*0),,Net:Send,'Dis:Border','imm',p_web.site.HTMLEditor,'UpdateDistrict')
    End
    do SendPacket
  End
  If loc:viewonly = false
    Case p_web.site.HTMLEditor  !
    of net:HTMLTinyMCE
        loc:options.Free(True)
        p_web.SetOption(loc:options,'width',60*8)
        p_web.TinyMceInit('Dis:Border',,loc:options)
    of net:HTMLRedactor
      loc:options.Free(True)
      p_web.SetOption(loc:options,'autoresize','false')
      p_web.RedactorInit('Dis:Border',,loc:options)
    of net:HTMLCKEditor4
      loc:options.Free(True)
      If p_web.site.CK4Skin Then p_web.SetOption(loc:options,'skin',p_web.site.CK4Skin).
      p_web.CKEditor4Init('Dis:Border',,loc:options)
    of net:HTMLAce
      loc:options.Free(True)
      p_web.SetOption(loc:options,'mode','ace/mode/' & p_web.site.AceSyntax)
      p_web.SetOption(loc:options,'theme','ace/theme/' & 'chrome')
      p_web.setOption(loc:options,'showLineNumbers',CHOOSE(p_web.site.AceShowLineNumbers=1,'^true','^false'))
      p_web.setOption(loc:options,'wrap', CHOOSE(p_web.site.AceWrapText=1,'^true','^false'))
      p_web.ACEInit('Dis:Border',,loc:options)
    End !a4
  End
  do SendPacket
  if p_web.site.FrontLoaded = 0 or loc:frontloading = net:GeneratingPage
    p_web.DivFooter(,,,0)
  end

Comment::Dis:Border  Routine
  data
loc:fieldclass string(StyleStringSize)
  code
  loc:fieldclass = p_web.Combine(p_web.site.style.formcomment,,)
  if Dis:Border:IsInvalid
    loc:fieldclass = clip(loc:fieldclass) & ' ' & p_web.site.style.FormCommentError
  end
  loc:comment = ''
  loc:fieldclass = Choose(not(1=0),loc:fieldclass,'nt-hidden ' & loc:fieldclass)
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
  else
    packet.append(p_web.DivHeader('UpdateDistrict_' & p_web.nocolon('Dis:Border') & '_comment',loc:fieldclass,Net:NoSend))
  End
  If 1=0
    loc:comment = ''
  End
  If p_web.site.FrontLoaded and loc:frontloading = net:GeneratingData
    p_web.script('$("#UpdateDistrict_' & p_web.nocolon('Dis:Border') & '_comment_div").html("'&clip(loc:comment)&'");')
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
  of lower('UpdateDistrict_nexttab_' & 0)
    Dis:Name = p_web.GetSessionValue('Dis:Name')
    do ValidateValue::Dis:Name
    If loc:Invalid
      loc:retrying = 1
      do Value::Dis:Name
      do Comment::Dis:Name ! allows comment style to be updated.
    End
    Dis:Description = p_web.GetSessionValue('Dis:Description')
    do ValidateValue::Dis:Description
    If loc:Invalid
      loc:retrying = 1
      do Value::Dis:Description
      do Comment::Dis:Description ! allows comment style to be updated.
    End
    Dis:Border = p_web.GetSessionValue('Dis:Border')
    do ValidateValue::Dis:Border
    If loc:Invalid
      loc:retrying = 1
      do Value::Dis:Border
      do Comment::Dis:Border ! allows comment style to be updated.
    End
    If loc:Invalid then exit.
  of lower('UpdateDistrict_nexttab_' & 1)
    If loc:Invalid then exit.
  End
  p_web.ntWiz('UpdateDistrict','next')

ChangeTab  routine
  p_web.ChangeTab(loc:TabStyle,'UpdateDistrict',loc:TabTo)

TabChanged  routine
  data
TabNumber   Long   !! remember that tabs are numbered from 0
TabHeading  String(252),dim(2)
  code
  tabnumber = p_web.GetValue('_tab_')
  tabheading[1]  = p_web.Translate('General')
  tabheading[2]  = p_web.Translate('Intermediate')
  p_web.SetSessionValue('showtab_UpdateDistrict',tabnumber) !! remember that tabs are numbered from 0

CallDiv    routine
  data
  code
  p_web.Ajax = 1
  p_web.PageName = p_web._unEscape(p_web.PageName)
  case lower(p_web.PageName)
  of lower('UpdateDistrict') & '_tabchanged'
     do TabChanged
  of lower('UpdateDistrict_tab_' & 0)
    do GenerateTab0
  of lower('UpdateDistrict_Dis:Name_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Dis:Name
        do AlertParent
      of 'timer'
        do refresh::Dis:Name
        do AlertParent
      else
        do Value::Dis:Name
      end
  of lower('UpdateDistrict_Dis:Description_value')
      case p_web.Event ! String
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Dis:Description
        do AlertParent
      of 'timer'
        do refresh::Dis:Description
        do AlertParent
      else
        do Value::Dis:Description
      end
  of lower('UpdateDistrict_Dis:Border_value')
      case p_web.Event ! Text
      of 'selected' !event:selected !257
      of 'accepted' !event:accepted !1
      orof 'childupdated'
        do Validate::Dis:Border
        do AlertParent
      of 'timer'
        do refresh::Dis:Border
        do AlertParent
      else
        do Value::Dis:Border
      end
  of lower('UpdateDistrict_tab_' & 1)
    do GenerateTab1
  End

SendPacket  routine
  p_web.ParseHTML(packet, 1, 0, NET:NoHeader)
  packet.setvalue('')
! NET:WEB:StagePRE

! ---------------------------------------------------------------------------------------------------------
PreInsert  Routine
  data
  code
  p_web.SetValue('UpdateDistrict_form:ready_',1)
  p_web.SetSessionValue('UpdateDistrict:Active',1)
  p_web.SetSessionValue('UpdateDistrict_CurrentAction',Net:InsertRecord)
  p_web.SetSessionValue('showtab_UpdateDistrict',0)   !
  Clear(Dis:record) ! Primes moved before auto-increment (PrimeRecord) call.
  Dis:Guid = glo:st.Random(16,st:Upper+st:Number)            ! taken from dictionary initial value
  p_web.SetSessionValue('Dis:Guid',Dis:Guid)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreCopy  Routine
  data
  code
  p_web.SetValue('UpdateDistrict_form:ready_',1)
  p_web.SetSessionValue('UpdateDistrict:Active',1)
  p_web.SetSessionValue('UpdateDistrict_CurrentAction',Net:CopyRecord)
  p_web.SetSessionValue('showtab_UpdateDistrict',0)  !
  p_web._PreCopyRecord(District,Dis:GuidKey)
  Dis:Guid = glo:st.Random(16,st:Upper+st:Number)
  p_web.SetSessionValue('Dis:Guid',Dis:Guid)
  ! here we need to copy the non-unique fields across
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
! this code runs After the record is loaded. To run code before, see InitForm Routine
PreUpdate  Routine
  data
loc:offset      Long
  code
  p_web.SetValue('UpdateDistrict_form:ready_',1)
  p_web.SetSessionValue('UpdateDistrict:Active',1)
  p_web.SetSessionValue('UpdateDistrict_CurrentAction',Net:ChangeRecord)
  p_web.SetSessionValue('UpdateDistrict:Primed',0)
  do SetFormSettings

! ---------------------------------------------------------------------------------------------------------
PreDelete       Routine
  data
  code
  p_web.SetValue('UpdateDistrict_form:ready_',1)
  p_web.SetSessionValue('UpdateDistrict_CurrentAction',Net:DeleteRecord)
  p_web.SetSessionValue('UpdateDistrict:Primed',0)
  p_web.SetSessionValue('showtab_UpdateDistrict',0)   !
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
          If p_web.IfExistsValue('Dis:Name')
            Dis:Name = p_web.GetValue('Dis:Name')
          End
          If p_web.IfExistsValue('Dis:Description')
            Dis:Description = p_web.GetValue('Dis:Description')
          End
          If p_web.IfExistsValue('Dis:Border')
            Dis:Border = p_web.GetValue('Dis:Border') ! STRING
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
  If p_web.GetSessionValue('UpdateDistrict:Primed') = 0 and Ans = Net:InsertRecord
    Get(District,0)
    GotFileZero = true
  End
  ! Check for duplicates
  If Duplicate(Dis:GuidKey) ! In SQL drivers this clears the Blob field, if Get(file,0) was done. TPS does not.
    loc:Invalid = 'Dis:Guid'
    if not loc:alert then loc:Alert = clip(p_web.site.DuplicateText) & ' GuidKey --> Dis:Guid = ' & clip(Dis:Guid).
  End
  If Duplicate(Dis:NameKey) ! In SQL drivers this clears the Blob field, if Get(file,0) was done. TPS does not.
    loc:Invalid = 'Dis:Name'
    if not loc:alert then loc:Alert = clip(p_web.site.DuplicateText) & ' NameKey --> ' & clip('Name')&' = ' & clip(Dis:Name).
  End
  If GotFileZero
  End

ValidateDelete  Routine
  p_web.DeleteSessionValue('UpdateDistrict_ChainTo')
  ! Check for restricted child records

ValidateRecord  Routine
  p_web.DeleteSessionValue('UpdateDistrict_ChainTo')

  ! Then add additional constraints set on the template
  loc:InvalidTab = -1
  ! tab = 1
    If  true
        loc:InvalidTab += 1
        do ValidateValue::Dis:Name
        If loc:Invalid then exit.
        do ValidateValue::Dis:Description
        If loc:Invalid then exit.
        do ValidateValue::Dis:Border
        If loc:Invalid then exit.
  End ! Tab Condition
  ! tab = 2
    If  true
        loc:InvalidTab += 1
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
    p_web.InsertAgain('UpdateDistrict')
    Clear(Dis:Record)
  Else
    p_web.SetSessionValue('UpdateDistrict:Active',0)
  End
PostCopy        Routine
  Data
  Code
  p_web.SetSessionValue('UpdateDistrict:Primed',0)
  p_web.SetSessionValue('UpdateDistrict:Active',0)

PostUpdate      Routine
  Data
  Code
  p_web.SetSessionValue('UpdateDistrict:Primed',0)
  p_web.SetSessionValue('UpdateDistrict:Active',0)

PostDelete      Routine
