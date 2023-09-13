

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76009.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('WEB76008.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('WEB76010.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('WEB76012.INC'),ONCE        !Req'd for module callout resolution
                     END


PageHeaderTag        PROCEDURE  (NetWebServerWorker p_web)
! Use this procedure to "embed" html in other pages.
! on the web page use <!-- Net:PageHeaderTag -->
!
! In this procedure set the packet stringTheory object, and call the SendPacket routine.
!
! EXAMPLE:
! packet.append('<strong>Hello World!</strong>'& p_web.CRLF)
! do SendPacket
loc:divname           string(252)
loc:parent            string(252)  ! should always be a lower-case string
loc:ContentBodyClass  string(StyleStringSize)
loc:LeftPanelClass    string(StyleStringSize)
loc:RightPanelClass   string(StyleStringSize)
loc:leftpanel         Long
loc:rightpanel        Long
packet                  StringTheory
timer                   long
loc:options             StringTheory ! options for jQuery calls
Loc:MenuStyle3   Long
Loc:MenuPos3     Long
  CODE
  If p_web.Event='callpopups'
    Return
  End
  GlobalErrors.SetProcedureName('PageHeaderTag')
  loc:parent = p_web.PlainText(lower(p_web.GetValue('_parentProc_')))
  If loc:parent <> ''
    loc:divname = lower(clip(loc:parent) & net:PARENTSEPARATOR & 'PageHeaderTag')
  Else
    loc:divname = lower('PageHeaderTag')
  End
    If p_web.Event = 'getsecwinsettings'   !NetTalk Web Menu
      GlobalErrors.SetProcedureName()
      Return
    end

  p_web.DivHeader(loc:divname,'nt-site-header-6 ui-widget-header ui-corner-top',,,' data-role="header"',1,,,'PageHeaderTag')
!----------- put your Header Panel html code here -----------------------------------
    !
      do SendPacket
      Do HeadingPlain
      do SendPacket
    p_web.ClearBrowse('PageHeaderTag')
    p_web.StoreValue('_menu_')
    loc:menuStyle3 = p_web.RestoreValue('_menu_')
    p_web.StoreValue('_menu_' & 'pos')
    loc:menuPos3 = p_web.RestoreValue('_menu_' & 'pos')
    If loc:MenuStyle3 = 0 then loc:MenuStyle3 = Net:Web:TaskPanel.
    If loc:menuPos3 = 0 then loc:menuPos3 = net:left.
    If loc:menuStyle3 <> Net:Web:Accordion and loc:menuStyle3 <> Net:Web:TaskPanel
      do WebMenus:3
      packet.append(p_web.comment('End Menu Popups'))
      do MenuPopups:3
      do SendPacket
    End
!----------- end of custom code ----------------------------------------
  do SendPacket
  p_web.DivFooter(,loc:divName)
    ! AfterDiv
  packet.append('<!-- Net:Busy -->')
  packet.append('<!-- Net:Message -->')
  do SendPacket
    Case Loc:MenuStyle3
    Of Net:Web:TaskPanel
    OrOf Net:Web:Accordion
      Case Loc:MenuPos3
      of net:Left
        loc:leftpanel = 1
      of net:Right
        loc:rightpanel = 1
      End
    End
  If loc:leftpanel and loc:rightpanel
    loc:ContentBodyClass = ' nt-contentpanel-lr'
    loc:LeftPanelClass = 'nt-leftpanel nt-leftpanel-lr'
    loc:RightPanelClass = 'nt-rightpanel nt-rightpanel-lr'
  ElsIf loc:leftpanel
    loc:ContentBodyClass = ' nt-contentpanel-l'
    loc:LeftPanelClass = 'nt-leftpanel nt-leftpanel-l'
  ElsIf loc:Rightpanel
    loc:ContentBodyClass = ' nt-contentpanel-r'
    loc:RightPanelClass = 'nt-rightpanel nt-rightpanel-r'
  Else
    loc:ContentBodyClass = ' nt-contentpanel-h'
  End
  If Loc:LeftPanel
    p_web.DivHeader(clip(loc:divname) & '_left',p_web.Combine(loc:LeftPanelClass,''),,,,1,,,'Left Panel')
      If Loc:MenuPos3 = net:Left and (loc:menuStyle3 = Net:Web:Accordion or loc:menuStyle3 = Net:Web:TaskPanel)
        do WebMenus:3
        packet.append(p_web.comment('End Menu Popups'))
        do MenuPopups:3
        do SendPacket
      End
    p_web.DivFooter(,clip(loc:divname) & '_left')
  End
  If Loc:RightPanel
    p_web.DivHeader(clip(loc:divname) & '_right',p_web.Combine(loc:RightPanelClass,''),,,,1,,,'Right Panel')
      If Loc:MenuPos3 = net:right and (loc:menuStyle3 = Net:Web:Accordion or loc:menuStyle3 = Net:Web:TaskPanel)
        do WebMenus:3
        packet.append(p_web.comment('End Menu Popups'))
        do MenuPopups:3
        do SendPacket
      End
    p_web.DivFooter(,clip(loc:divname) & '_right')
  End
  If (p_web.site.ContentBody) and p_web.Ajax = 0
    p_web.DivHeader(p_web.site.ContentBody,p_web.Combine(p_web.site.contentbodydivclass,loc:ContentBodyClass),,,,,,,'Content Body')
  end
  GlobalErrors.SetProcedureName()
  Return

!--------------------------------------
SendPacket  routine
  p_web.ParseHTML(packet,1,0,NET:NoHeader)
  packet.SetValue('')


MenuPopups:3  Routine

WebMenus:Accordion:3  Routine
  data
loc:menunumber  long
  code
  
  do StartMenu:3
  packet.append(p_web.DivHeader(clip('menu'),p_web.Combine('nt-noprint',p_web.site.style.FormTabOuter,' nt-menu-div nt-menu-accordion nt-left nt-width-150px'),Net:NoSend))
        packet.append('<h3 class="'&p_web.combine(,' nt-accordion-icon-right')&'"' & p_web.CreateTip() & '>'& |
                         '<div id="'&clip('menu')&'_1_name'&'" class="nt-flex">' & |
                         '<div>' & p_web.Translate('Home',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0)& '</div>' & |
                         '</div>' &|
                         '</h3>' & p_web.CRLF & |
                 p_web.DivHeader(clip('menu')&'_1',p_web.combine(,' nt-padding-1 nt-accordion-menu-body'),Net:NoSend))
        do Menu:1:3
        packet.append(p_web.DivFooter(Net:NoSend))
        p_web.SetSessionValueDefault('PageHeaderTag_MenuOpen',loc:menunumber)
        loc:menunumber += 1
        packet.append('<h3 class="'&p_web.combine(,' nt-accordion-icon-right')&'"' & p_web.CreateTip() & '>'& |
                         '<div id="'&clip('menu')&'_3_name'&'" class="nt-flex">' & |
                         '<div>' & p_web.Translate('Maps',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0)& '</div>' & |
                         '</div>' &|
                         '</h3>' & p_web.CRLF & |
                 p_web.DivHeader(clip('menu')&'_3',p_web.combine(,' nt-padding-1 nt-accordion-menu-body'),Net:NoSend))
        do Menu:3:3
        packet.append(p_web.DivFooter(Net:NoSend))
        p_web.SetSessionValueDefault('PageHeaderTag_MenuOpen',loc:menunumber)
        loc:menunumber += 1
        packet.append('<h3 class="'&p_web.combine(,' nt-accordion-icon-right')&'"' & p_web.CreateTip() & '>'& |
                         '<div id="'&clip('menu')&'_2_name'&'" class="nt-flex">' & |
                         '<div>' & p_web.Translate('Browse',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0)& '</div>' & |
                         '</div>' &|
                         '</h3>' & p_web.CRLF & |
                 p_web.DivHeader(clip('menu')&'_2',p_web.combine(,' nt-padding-1 nt-accordion-menu-body'),Net:NoSend))
        do Menu:2:3
        packet.append(p_web.DivFooter(Net:NoSend))
        p_web.SetSessionValueDefault('PageHeaderTag_MenuOpen',loc:menunumber)
        loc:menunumber += 1
  packet.append(p_web.DivFooter(Net:NoSend))
  do EndMenu:3
  ! javascript to make menu work
  loc:options.Free(True)
  p_web.SetOption(loc:options,'heightStyle','content')
  p_web.SetOption(loc:options,'icons','{{ ''header'': ''ui-icon-' & clip('triangle-1-e') & ''', ''activeHeader'': ''ui-icon-' & clip('triangle-1-s') & ''' }')
  p_web.SetOption(loc:options,'active',p_web.GetSessionValue('PageHeaderTag_MenuOpen') )
  p_web.SetOption(loc:options,'activate','function(event, ui) {{ SetSessionValue(''PageHeaderTag_MenuOpen'',$(this).accordion("option","active")); }')
  p_web.jQuery('#' & lower('menu') & '_div','accordion',loc:options)
WebMenus:TaskPanel:3  Routine
  data
loc:options             StringTheory ! options for jQuery calls
  code
  
  do StartMenu:3
  ! menu div
  packet.append(p_web.DivHeader('menu',p_web.Combine('nt-noprint',' nt-menu-div nt-menu-taskpanel nt-left nt-width-150px'),Net:NoSend,,,,,,'Taskpanel Menu') & p_web.CRLF)
  ! Task Panel header - 'Home'
        packet.append('<a href="'&p_web._jsok(p_web._MakeUrl(clip('IndexPage')))&'"' & p_web.CreateTip() & ' id="'&p_web._jsok('menu') & '_1" class="'& p_web.combine('ui-corner-all nt-menu-item-alone',,'') & '">' & |
                        '<div id="'&clip('menu')&'_1_name'&'" class="nt-menu-text">' & |
                        '<div>' & p_web.Translate('Home',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0) & '</div>' &|
                        '</div></a>')
  ! Task Panel header - 'Maps'
        packet.append('<div' & p_web.CreateTip() & ' id="' & p_web._jsok('menu') & '_3" class="' & p_web.combine(,'') & '">' & |
                                '<h3 class="' & p_web.combine(' nt-accordion-icon-right') & '">'&|
                                '<div id="'&clip('menu')&'_3_name'&'" class="nt-flex">' & |
                                '<div>' & p_web.Translate('Maps',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0) & '</div>' & |
                                '</div>' & |
                                '</h3><div class="'&p_web.combine('nt-menu-items-background',' nt-padding-1 nt-accordion-menu-body')&'">' & p_web.CRLF )
        do Menu:3:3
        packet.append('</div></div>')
        p_web.SetSessionValueDefault('open_PageHeaderTag_3','0')  ! if not set earlier - 0 = first menu.
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'icons','{{ ''header'': ''ui-icon-' & clip('triangle-1-e') & ''', ''activeHeader'': ''ui-icon-' & clip('triangle-1-s') & '''}')
        p_web.SetOption(loc:options,'active',p_web.GetSessionValue('open_PageHeaderTag_3'))
        p_web.SetOption(loc:options,'activate','function(event, ui) {{ SetSessionValue(''open_PageHeaderTag_3'',$(this).accordion( "option", "active" ));}')
        p_web.jQuery('#' & p_web._jsok('menu')&'_3','accordion',loc:options)
  ! Task Panel header - 'Browse'
        packet.append('<div' & p_web.CreateTip() & ' id="' & p_web._jsok('menu') & '_2" class="' & p_web.combine(,'') & '">' & |
                                '<h3 class="' & p_web.combine(' nt-accordion-icon-right') & '">'&|
                                '<div id="'&clip('menu')&'_2_name'&'" class="nt-flex">' & |
                                '<div>' & p_web.Translate('Browse',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0) & '</div>' & |
                                '</div>' & |
                                '</h3><div class="'&p_web.combine('nt-menu-items-background',' nt-padding-1 nt-accordion-menu-body')&'">' & p_web.CRLF )
        do Menu:2:3
        packet.append('</div></div>')
        p_web.SetSessionValueDefault('open_PageHeaderTag_2','0')  ! if not set earlier - 0 = first menu.
        loc:options.Free(True)
        p_web.SetOption(loc:options,'collapsible','true')
        p_web.SetOption(loc:options,'heightStyle','content')
        p_web.SetOption(loc:options,'icons','{{ ''header'': ''ui-icon-' & clip('triangle-1-e') & ''', ''activeHeader'': ''ui-icon-' & clip('triangle-1-s') & '''}')
        p_web.SetOption(loc:options,'active',p_web.GetSessionValue('open_PageHeaderTag_2'))
        p_web.SetOption(loc:options,'activate','function(event, ui) {{ SetSessionValue(''open_PageHeaderTag_2'',$(this).accordion( "option", "active" ));}')
        p_web.jQuery('#' & p_web._jsok('menu')&'_2','accordion',loc:options)
  packet.append(p_web.divFooter(net:nosend,'Task Panel Menu End'))
  do EndMenu:3
WebMenus:DoubleDrop:3  Routine
  
  do StartMenu:3
  packet.append(p_web.DivHeader('menu',' nt-menu-div ui-corner-br',Net:NoSend,,,1,,,'Double Drop Menu','nav'))
  packet.append('<div id="'& clip('menu') & '_burger" class="' & p_web.combine('nt-noprint nt-small-menu ') & '">' &|
    p_web.CreateIcon(clip('menu ui-icons-dark ui-icons-32'),'burger') & |
    '</div>' & p_web.CRLF)
  packet.append('<ul id="'&clip('menu')&'" class="'&clip(' nt-menu')&'">' & p_web.CRLF)
        packet.append('<li class="nt-menu-nodrop"><a ' & p_web.CreateTip() & ' class="'&p_web.Combine('nt-menu-button nt-menu-button-drop',, )&'" href="'&p_web._jsok(p_web._MakeUrl(clip('IndexPage')))&'">' & |   !a
          '<div class="nt-menu-text">' & p_web.Translate('Home',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0)&'</div></a>' & p_web.CRLF)
        do SendPacket
        do Menu:1:3
        packet.append('</li>' & p_web.CRLF)
        packet.append('<li class="nt-menu-drop"><a ' & p_web.CreateTip() & ' class="'&p_web.Combine('nt-menu-button nt-menu-button-drop',,)&'" href="#">' & |  !b
          '<div class="nt-menu-text">' & p_web.Translate('Maps',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0)&'</div></a>' & p_web.CRLF)
        do SendPacket
        do Menu:3:3
        packet.append('</li>' & p_web.CRLF)
        packet.append('<li class="nt-menu-drop"><a ' & p_web.CreateTip() & ' class="'&p_web.Combine('nt-menu-button nt-menu-button-drop',,)&'" href="#">' & |  !b
          '<div class="nt-menu-text">' & p_web.Translate('Browse',Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0)&'</div></a>' & p_web.CRLF)
        do SendPacket
        do Menu:2:3
        packet.append('</li>' & p_web.CRLF)
  packet.append('</ul>' & p_web.CRLF & p_web.DivFooter(net:NoSend,'Double Drop Menu End',,,'nav'))
  do EndMenu:3
  ! javascript to make menu work.
  loc:options.Free(True)
  p_web.SetOption(loc:options,'ul',clip('menu'))    ! id of first UL for the menu
  p_web.SetOption(loc:options,'burger',clip('menu') & '_burger')  ! id of hamburger
  p_web.SetOption(loc:options,'icons','{{ submenu: "ui-icon-'& clip('triangle-1-s') & '"}')
  p_web.SetOption(loc:options,' position','{{ my: "left top", at: "left+0 bottom+1"}')
  p_web.SetOption(loc:options,'touch',p_web.IsMenuTouch(),true) ! doesn't override existing setting.
  p_web.jQuery('#' & clip('menu'),'ntmenu',loc:options)
  do SendPacket

!--- Menu ---  'Home'
Menu:1:3  Routine
  Case loc:menuStyle3
  Of net:web:ddm
    packet.append('<ul id="ul-1-3" class="nt-menu-items" style="display:none;">' & p_web.CRLF)
        Case loc:menuStyle3
        Of Net:Web:Accordion
          packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
          packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Home','IndexPage',,'','',net:OpenAsLink,,,,,,,,,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
          packet.append('</div>' & p_web.CRLF)
          do SendPacket
        End ! Case loc:menuStyle3 [3]
    If packet.Instring('<li')
      packet.append('</ul>' & p_web.CRLF)
    Else
      packet.setValue('')
    End
  Of net:web:accordion
    packet.append('<div class="nt-menu-accordion-items">' & p_web.CRLF)
        Case loc:menuStyle3
        Of Net:Web:Accordion
          packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
          packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Home','IndexPage',,'','',net:OpenAsLink,,,,,,,,,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
          packet.append('</div>' & p_web.CRLF)
          do SendPacket
        End ! Case loc:menuStyle3 [3]
    packet.append('</div>' & p_web.CRLF)
  Of net:web:taskpanel
        Case loc:menuStyle3
        Of Net:Web:Accordion
          packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
          packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Home','IndexPage',,'','',net:OpenAsLink,,,,,,,,,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
          packet.append('</div>' & p_web.CRLF)
          do SendPacket
        End ! Case loc:menuStyle3 [3]
  End ! Case loc:menuStyle3 [1]
  do SendPacket

!--- Menu ---  'Maps'
Menu:3:3  Routine
  Case loc:menuStyle3
  Of net:web:ddm
    packet.append('<ul id="ul-3-3" class="nt-menu-items" style="display:none;">' & p_web.CRLF)
    
      !--- Menu Item ---  'Maps'  --- 'General' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('GeneralMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'General','GeneralMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Maps'  --- 'Accidents' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('AccidentsMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Accidents','AccidentsMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Maps'  --- 'Patrols' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('PatrolMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Patrols','PatrolMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    If packet.Instring('<li')
      packet.append('</ul>' & p_web.CRLF)
    Else
      packet.setValue('')
    End
  Of net:web:accordion
    packet.append('<div class="nt-menu-accordion-items">' & p_web.CRLF)
    
      !--- Menu Item ---  'Maps'  --- 'General' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('GeneralMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'General','GeneralMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Maps'  --- 'Accidents' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('AccidentsMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Accidents','AccidentsMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Maps'  --- 'Patrols' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('PatrolMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Patrols','PatrolMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    packet.append('</div>' & p_web.CRLF)
  Of net:web:taskpanel
    
      !--- Menu Item ---  'Maps'  --- 'General' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('GeneralMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'General','GeneralMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Maps'  --- 'Accidents' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('AccidentsMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Accidents','AccidentsMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Maps'  --- 'Patrols' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('PatrolMap',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Patrols','PatrolMap',,,'',net:OpenAsLink,Net:Form,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
  End ! Case loc:menuStyle3 [1]
  do SendPacket

!--- Menu ---  'Browse'
Menu:2:3  Routine
  Case loc:menuStyle3
  Of net:web:ddm
    packet.append('<ul id="ul-2-3" class="nt-menu-items" style="display:none;">' & p_web.CRLF)
    
      !--- Menu Item ---  'Browse'  --- 'Accident' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowseAccident',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Accident','BrowseAccident',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Browse'  --- 'District' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowseDistrict',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'District','BrowseDistrict',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Browse'  --- 'Patrol Area' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowsePatrolArea',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Patrol Area','BrowsePatrolArea',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    If packet.Instring('<li')
      packet.append('</ul>' & p_web.CRLF)
    Else
      packet.setValue('')
    End
  Of net:web:accordion
    packet.append('<div class="nt-menu-accordion-items">' & p_web.CRLF)
    
      !--- Menu Item ---  'Browse'  --- 'Accident' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowseAccident',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Accident','BrowseAccident',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Browse'  --- 'District' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowseDistrict',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'District','BrowseDistrict',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Browse'  --- 'Patrol Area' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowsePatrolArea',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Patrol Area','BrowsePatrolArea',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    packet.append('</div>' & p_web.CRLF)
  Of net:web:taskpanel
    
      !--- Menu Item ---  'Browse'  --- 'Accident' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowseAccident',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Accident','BrowseAccident',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Browse'  --- 'District' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowseDistrict',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'District','BrowseDistrict',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
    
      !--- Menu Item ---  'Browse'  --- 'Patrol Area' -- Level = 1 -- pParent = 0 -- found=0
          If p_web.CanCall('BrowsePatrolArea',0,,) = net:ok
            case loc:menuStyle3
            of Net:Web:Ddm
              packet.append('<li data-pos="" class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End
            Case loc:menuStyle3
            of Net:Web:Taskpanel
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            of Net:Web:Accordion
              packet.append('<div class="' & p_web.Combine('nt-menu-item',,) & '">' & p_web.CRLF)
            End ! Case loc:menuStyle3 [4]
              packet.append(p_web.CreateMenuItem(loc:MenuStyle3,'Patrol Area','BrowsePatrolArea',,,'',net:OpenAsLink,Net:Browse,,,,'16','16','',0,Net:HtmlOk * 0 + Net:UnsafeHtmlOk * 0, ,,) & p_web.CRLF)
            case loc:menuStyle3
            of net:web:ddm
              packet.append('</li>' & p_web.CRLF)
            of net:web:taskpanel
            orof Net:Web:Accordion
              packet.append('</div>' & p_web.CRLF)
            end ! loc:menuStyle3 [7]
          End ! TmpPutend
  End ! Case loc:menuStyle3 [1]
  do SendPacket

WebMenus:3   routine
  Case loc:MenuStyle3
  of Net:Web:Accordion
    do WebMenus:Accordion:3
  Of Net:Web:Ddm
    do WebMenus:DoubleDrop:3
  Of Net:Web:TaskPanel
    do WebMenus:TaskPanel:3
  End

StartMenu:3  Routine

EndMenu:3   routine
  packet.append(p_web.comment('Menu Popups'))
  do SendPacket

HeadingPlain  Routine
  packet.append(p_web.AsciiToUTF(|
    '<<h1>NetTalk Maps Example<</h1><13,10>'&|
    '',net:OnlyIfUTF,net:StoreAsAscii))
