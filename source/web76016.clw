

   MEMBER('web76.clw')                                     ! This is a MEMBER module

                     MAP
                       INCLUDE('WEB76016.INC'),ONCE        !Local module procedure declarations
                     END


PageFooterTag        PROCEDURE  (NetWebServerWorker p_web)
! Use this procedure to "embed" html in other pages.
! on the web page use <!-- Net:PageFooterTag -->
!
! In this procedure set the packet stringTheory object, and call the SendPacket routine.
!
! EXAMPLE:
! packet.append('<strong>Hello World!</strong>'& p_web.CRLF)
! do SendPacket
loc:divname           string(252)
loc:parent            string(252)  ! should always be a lower-case string
packet                  StringTheory
timer                   long
loc:options             StringTheory ! options for jQuery calls
  CODE
  If p_web.Event='callpopups'
    Return
  End
  GlobalErrors.SetProcedureName('PageFooterTag')
  loc:parent = p_web.PlainText(lower(p_web.GetValue('_parentProc_')))
  If loc:parent <> ''
    loc:divname = lower(clip(loc:parent) & net:PARENTSEPARATOR & 'PageFooterTag')
  Else
    loc:divname = lower('PageFooterTag')
  End

  If (p_web.site.ContentBody) and p_web.Ajax = 0
    p_web.DivFooter(,'contentbody_div')
  end
  packet.append('<style>:root{{--footer-height:'& clip('3rem')&';--minus-footer-height:-'& clip('3rem') &';}</style>')
  do SendPacket
  p_web.DivHeader(loc:divname,'nt-left nt-width-100 nt-site-footer',,,' data-role="footer"',1,,,'PageFooterTag')
!----------- put your Header Panel html code here -----------------------------------
    !
      do SendPacket
    If (p_web.GetSessionLoggedIn() )
      Do LoggedIn
      do SendPacket
    End
    If (p_web.GetSessionLoggedIn() = 0)
      Do NotLoggedIn
      do SendPacket
    End
    if (p_web.GetSessionLoggedIn() and p_web.PageName <> p_web.site.LoginPage)
      ! parameter 1 is the session time
      ! parameter 2 is the name of the login page.
      ! parameter 3 is the id of the <div> in the html.
      p_web.Script('startCountDown('& int(p_web.site.SessionExpiryAfterHS/100) &',"'& clip(p_web.site.LoginPage) &'","countdown");')
    end
  
!----------- end of custom code ----------------------------------------
  do SendPacket
  p_web.DivFooter(,loc:divName)
  GlobalErrors.SetProcedureName()
  Return

!--------------------------------------
SendPacket  routine
  p_web.ParseHTML(packet,1,0,NET:NoHeader)
  packet.SetValue('')

LoggedIn  Routine
  packet.append(p_web.AsciiToUTF(|
    '<<div>Copyright <<!-- Net:d:year --><</div><13,10>'&|
    '',net:OnlyIfUTF,net:StoreAsAscii))
NotLoggedIn  Routine
  packet.append(p_web.AsciiToUTF(|
    '<<div>Copyright <<!-- Net:d:year --><</div><13,10>'&|
    '',net:OnlyIfUTF,net:StoreAsAscii))
