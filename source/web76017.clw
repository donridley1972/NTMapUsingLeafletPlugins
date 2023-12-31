

   MEMBER('web76.clw')                                     ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('NetWeb.inc'),ONCE

                     MAP
                       INCLUDE('WEB76017.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('WEB76002.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
WebServer PROCEDURE (<NetWebServer pServer>)

WebLog               GROUP,PRE(web)                        !
EnableLogging        LONG(1)                               !
LastGet              STRING(4096)                          !
LastPost             STRING(4096)                          !
StartDate            LONG                                  !
StartTime            LONG                                  !
PagesServed          LONG                                  !
                     END                                   !
LogQueue             QUEUE,PRE(LogQ)                       !
Port                 STRING(30)                            !
Socket               LONG                                  !
Thread               LONG                                  !
Date                 LONG                                  !
Time                 LONG                                  !
Desc                 STRING(4096)                          !
                     END                                   !
WebPerformance       GROUP,PRE(wp)                         !
StartDateA           LONG                                  !
StartTimeA           LONG                                  !
NumberOfRequests     LONG                                  !
NumberOfSpiderRequests LONG                                !
NumberOf404Requests  LONG                                  !
NumberOf500Requests  LONG                                  !
TotalRequestTime     REAL                                  !
NumberOfRequestsLTHalf LONG                                !
NumberOfRequestsLTOne LONG                                 !
NumberOfRequestsLTTwo LONG                                 !
NumberOfRequestsLTFive LONG                                !
NumberOfRequestsGTFive LONG                                !
RequestTimeLTHalf    REAL                                  !
RequestTimeLTOne     REAL                                  !
RequestTimeLTTwo     REAL                                  !
RequestTimeLTFive    REAL                                  !
RequestTimeGTFive    REAL                                  !
AverageRequestTimeLTHalf REAL                              !
AverageRequestTimeLTOne REAL                               !
AverageRequestTimeLTTwo REAL                               !
AverageRequestTimeLTFive REAL                              !
AverageRequestTimeGTFive REAL                              !
MaximumThreads       LONG                                  !
MaximumSessions      LONG                                  !
MaximumSessionData   LONG                                  !
MaximumThreadPool    LONG                                  !
MaximumConnections   LONG                                  !
MaximumWebSocketConnections LONG                           !
NumberOfSessions     LONG                                  !
NumberOfSessionData  LONG                                  !
NumberOfThreads      LONG                                  !
NumberOfThreadPool   LONG                                  !
NumberOfConnections  LONG                                  !
NumberofWebSocketConnections LONG                          !
                     END                                   !
BannedQueue          QUEUE,PRE(BannedQueue)                !
IPAddress            STRING(45)                            !
                     END                                   !
ServerSettings       GROUP,PRE()                           !
set:SecurePort       LONG                                  !
set:InsecurePort     LONG                                  !
set:AccountName      STRING(256)                           !
set:Domains          STRING(2048)                          !
set:Passwords        STRING(2048)                          !
set:CertificatesFolder STRING(256)                         !
set:LastCertificateCheckDate LONG                          !
set:Staging          LONG                                  !
set:WebFolder        STRING(256)                           !
set:AcmeFolder       STRING(256)                           !
set:BindToIpAddress  STRING(100)                           !
set:SessionTimeout   LONG                                  !
set:xFrameOptions    STRING(256)                           !
set:AccessControlAllowOrigin STRING(256)                   !
set:StrictTransportSecurity STRING(50)                     !
set:ContentSecurityPolicy STRING(256)                      !
set:ContentSecurityPolicyReportOnly STRING(256)            !
set:ReferrerPolicy   STRING(50)                            !
                     END                                   !
ThisSessionStore   &NetSessionsQueue
s_web              &NetWebServer
Net:ShortInit      Long
loc:RequestData    Group(NetWebServerRequestDataType).
loc:OverString     String(size(loc:RequestData)),over(loc:RequestData)
loc:ShuttingDown   Long
loc:Index          Long
Window               WINDOW('NetTalk Web Server'),AT(,,441,315),FONT('Segoe UI',10,,FONT:regular,CHARSET:ANSI), |
  DOUBLE,AUTO,ICON(ICON:Clarion),GRAY,IMM,SYSTEM
                       SHEET,AT(5,5,431,290),USE(?SHEET1)
                         TAB('log'),USE(?TabLog)
                           GROUP('Logging Group'),AT(13,30,415,245),USE(?LogGroup)
                             LIST,AT(18,35,405,70),USE(?LogQueue),VSCROLL,COLOR(,COLOR:Black,00F0F0F0h),GRID(00F0F0F0h), |
  FORMAT('51L(2)|M~IP Address~@s30@28L(2)|M~Socket~@n7@28L(2)|M~Thread~@n3@51L(2)|M~Dat' & |
  'e~@D17B@36L(2)|M~Time~@T4B@1020L(2)|M~Description~@s255@'),FROM(LogQueue)
                             TEXT,AT(18,110,200,135),USE(web:LastGet),VSCROLL
                             TEXT,AT(223,110,200,135),USE(web:LastPost),VSCROLL
                             OPTION('Log:'),AT(18,249,141,22),USE(web:EnableLogging),BOXED
                               RADIO('No'),AT(25,257),USE(?Option1:Radio1),VALUE('0')
                               RADIO('Screen'),AT(53,257),USE(?Option1:Radio2),VALUE('1')
                               RADIO('Screen && Disk'),AT(98,257),USE(?Option1:Radio3),VALUE('2')
                             END
                             BUTTON('Clear'),AT(162,254,45,16),USE(?Clear)
                           END
                         END
                         TAB('Performance'),USE(?TabPerformance)
                           STRING('Started At:'),AT(14,29),USE(?StartDate),TRN
                           STRING(@d17),AT(92,29),USE(wp:StartDateA),TRN
                           STRING(@t1),AT(157,29),USE(wp:StartTimeA),TRN
                           GROUP('Number of Requests'),AT(14,43,173,82),USE(?Perfrequests),BOXED
                             STRING('Total:'),AT(23,55),USE(?NumberOfRequests),TRN
                             STRING(@n14),AT(86,55),USE(wp:NumberOfRequests),RIGHT,TRN
                             STRING('Spiders:'),AT(23,68),USE(?NumberOfSpiderRequests),TRN
                             STRING(@n14),AT(86,68),USE(wp:NumberOfSpiderRequests),RIGHT,TRN
                             STRING('Not Found (404):'),AT(23,81),USE(?NumberOf404Requests),TRN
                             STRING(@n14),AT(86,81),USE(wp:NumberOf404Requests),RIGHT,TRN
                             STRING('Too Busy (500):'),AT(23,94),USE(?NumberOf500Requests),TRN
                             STRING(@n14),AT(86,94),USE(wp:NumberOf500Requests),RIGHT,TRN
                             STRING('Total Time:'),AT(23,107),USE(?TotalRequestTime),TRN
                             STRING(@n10.2),AT(103,107),USE(wp:TotalRequestTime),RIGHT,TRN
                           END
                           GROUP('Performance Breakdown'),AT(14,128,412,60),USE(?PerfBreakdown),BOXED
                             STRING('<< 0.5'),AT(136,136),USE(?LT05),FONT(,,,FONT:bold),RIGHT,TRN
                             STRING('<< 1'),AT(207,136),USE(?LT1),FONT(,,,FONT:bold),RIGHT,TRN
                             STRING('<< 2'),AT(271,136),USE(?LT2),FONT(,,,FONT:bold),RIGHT,TRN
                             STRING('<< 5'),AT(335,136),USE(?LT5),FONT(,,,FONT:bold),RIGHT,TRN
                             STRING('> 5'),AT(399,136),USE(?GT5),FONT(,,,FONT:bold),RIGHT,TRN
                             STRING('Number of requests:'),AT(23,149),USE(?Numberbreakdown),TRN
                             STRING(@n11),AT(99,149),USE(wp:NumberOfRequestsLTHalf),RIGHT,TRN
                             STRING(@n11),AT(163,149),USE(wp:NumberOfRequestsLTOne),RIGHT,TRN
                             STRING(@n11),AT(227,149),USE(wp:NumberOfRequestsLTTwo),RIGHT,TRN
                             STRING(@n11),AT(291,149),USE(wp:NumberOfRequestsLTFive),RIGHT,TRN
                             STRING(@n11),AT(355,149),USE(wp:NumberOfRequestsGTFive),RIGHT,TRN
                             STRING('Total Response Time (s):'),AT(23,162),USE(?totaltimeBreakdown),TRN
                             STRING(@n11),AT(99,162),USE(wp:RequestTimeLTHalf),RIGHT,TRN
                             STRING(@n11),AT(163,162),USE(wp:RequestTimeLTOne),RIGHT,TRN
                             STRING(@n11),AT(227,162),USE(wp:RequestTimeLTTwo),RIGHT,TRN
                             STRING(@n11),AT(291,162),USE(wp:RequestTimeLTFive),RIGHT,TRN
                             STRING(@n11),AT(355,162),USE(wp:RequestTimeGTFive),RIGHT,TRN
                             STRING('Average Response Time (s):'),AT(23,175),USE(?timeBreakdown),TRN
                             STRING(@n4.2),AT(133,175),USE(wp:AverageRequestTimeLTHalf),RIGHT,TRN
                             STRING(@n4.2),AT(197,175),USE(wp:AverageRequestTimeLTOne),RIGHT,TRN
                             STRING(@n4.2),AT(261,175),USE(wp:AverageRequestTimeLTTwo),RIGHT,TRN
                             STRING(@n4.2),AT(325,175),USE(wp:AverageRequestTimeLTFive),RIGHT,TRN
                             STRING(@n10),AT(359,175),USE(wp:AverageRequestTimeGTFive),RIGHT,TRN
                           END
                           GROUP('Resources'),AT(14,195,232,90),USE(?PerfResources),BOXED
                             STRING('Current'),AT(128,203),USE(?Current),FONT(,,,FONT:bold),TRN
                             STRING('Maximum'),AT(182,203),USE(?Maximum),FONT(,,,FONT:bold),TRN
                             STRING('Threads:'),AT(23,216),USE(?Threads),TRN
                             STRING(@n11),AT(99,216),USE(wp:NumberOfThreads),RIGHT,TRN
                             STRING(@n11),AT(162,216),USE(wp:MaximumThreads),RIGHT,TRN
                             STRING('Sessions'),AT(23,229),USE(?Sessions),TRN
                             STRING(@n11),AT(99,229),USE(wp:NumberOfSessions),RIGHT,TRN
                             STRING(@n11),AT(162,229),USE(wp:MaximumSessions),RIGHT,TRN
                             STRING('Session Data:'),AT(23,242),USE(?SessionData),TRN
                             STRING(@n11),AT(99,242),USE(wp:NumberOfSessionData),RIGHT,TRN
                             STRING(@n11),AT(162,242),USE(wp:MaximumSessionData),RIGHT,TRN
                             STRING('Thread Pool:'),AT(23,255),USE(?threadPool),TRN
                             STRING(@n11),AT(99,255),USE(wp:NumberOfThreadPool),RIGHT,TRN
                             STRING(@n11),AT(162,255),USE(wp:MaximumThreadPool),RIGHT,TRN
                             STRING('Connections:'),AT(23,268),USE(?Connections),TRN
                             STRING(@n11),AT(99,268),USE(wp:NumberOfConnections),RIGHT,TRN
                             STRING(@n11),AT(162,268),USE(wp:MaximumConnections),RIGHT,TRN
                           END
                           BUTTON('Clear'),AT(251,267,45,16),USE(?ClearStatsButton)
                         END
                         TAB('Settings'),USE(?TAB1)
                           SHEET,AT(13,22,430,260),USE(?SettingsSheet)
                             TAB('Security'),USE(?SecurityTab)
                               PROMPT('Secure Port:'),AT(17,43),USE(?set:SecurePort:Prompt),TRN
                               ENTRY(@n6),AT(117,43,60,10),USE(set:SecurePort),OVR
                               CHECK('Testing'),AT(199,43),USE(set:Staging),TRN
                               PROMPT('Insecure Port:'),AT(17,59),USE(?set:InsecurePort:Prompt),TRN
                               ENTRY(@n6),AT(117,59,60,10),USE(set:InsecurePort),OVR
                               BUTTON('Certificates'),AT(287,43),USE(?GetCertificatesButton)
                               BUTTON('Restart Server'),AT(357,43),USE(?RestartButton)
                               PROMPT('Certificates Folder:'),AT(17,75),USE(?set:CertificatesFolder:Prompt),TRN
                               ENTRY(@s255),AT(117,75,317,12),USE(set:CertificatesFolder)
                               PROMPT('Acme Web Folder:'),AT(17,91),USE(?set:AcmeFolder:Prompt),TRN
                               ENTRY(@s255),AT(117,91,317,12),USE(set:AcmeFolder)
                               PROMPT('CA Account:'),AT(17,107),USE(?set:AccountName:Prompt),TRN
                               ENTRY(@s255),AT(117,107,317,12),USE(set:AccountName)
                               PROMPT('Bind To IP Address:'),AT(17,123),USE(?set:BindToIpAddress:Prompt),TRN
                               ENTRY(@s100),AT(117,123,317,12),USE(set:BindToIpAddress)
                               PROMPT('Domains:'),AT(17,139),USE(?set:Domains:Prompt),TRN
                               TEXT,AT(117,139,317,35),USE(set:Domains),HVSCROLL
                               TEXT,AT(117,184,317,70),USE(?LogText),HVSCROLL
                             END
                             TAB('Site'),USE(?SiteTab)
                               PROMPT('Web folder:'),AT(21,40),USE(?set:WebFolder:Prompt),TRN
                               ENTRY(@s255),AT(121,40,300,10),USE(set:WebFolder)
                               PROMPT('Session Timeout:'),AT(21,56),USE(?set:SessionTimeout:Prompt),TRN
                               ENTRY(@t1),AT(121,56,40,12),USE(set:SessionTimeout)
                               GROUP('Server Headers'),AT(21,76,405,112),USE(?ServerHeaders),BOXED
                                 PROMPT('X-Frame-Options:'),AT(31,92),USE(?set:xFrameOptions:Prompt),TRN
                                 ENTRY(@s255),AT(161,92,250,12),USE(set:xFrameOptions)
                                 PROMPT('Access-Control-Allow-Origin:'),AT(31,108),USE(?set:AccessControlAllowOrigin:Prompt), |
  TRN
                                 ENTRY(@s255),AT(161,108,250,12),USE(set:AccessControlAllowOrigin)
                                 PROMPT('Strict-Transport-Security:'),AT(31,124),USE(?set:StrictTransportSecurity:Prompt),TRN
                                 ENTRY(@s255),AT(161,124,250,12),USE(set:StrictTransportSecurity)
                                 PROMPT('Content-Security-Policy:'),AT(31,140),USE(?set:ContentSecurityPolicy:Prompt),TRN
                                 ENTRY(@s255),AT(161,140,250,12),USE(set:ContentSecurityPolicy)
                                 PROMPT('Content-Security-Policy-Report-Only:'),AT(31,156),USE(?set:ContentSecurityPolicyReportOnly:Prompt), |
  TRN
                                 ENTRY(@s255),AT(161,156,250,12),USE(set:ContentSecurityPolicyReportOnly)
                                 PROMPT('Referrer-Policy:'),AT(31,172),USE(?set:ReferrerPolicy:Prompt),TRN
                                 ENTRY(@s255),AT(161,172,250,12),USE(set:ReferrerPolicy)
                               END
                             END
                           END
                         END
                       END
                       BUTTON('Close'),AT(391,298,45,14),USE(?Close)
                       BUTTON('Button1'),AT(13,299),USE(?BUTTON1)
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
!Local Data Classes
ThisWebServer        CLASS(NetWebServer)                   ! Generated by NetTalk Extension (Class Definition)
AddLog                 PROCEDURE(FILE p_File,*String p_Field,*String p_Name,String p_DataString,<String p_ip>),DERIVED
AddLog                 PROCEDURE(String p_Data,<string p_ip>),DERIVED
StartNewThread         PROCEDURE(NetWebServerRequestDataType p_RequestData),DERIVED
TakeEvent              PROCEDURE(),DERIVED

                     END


  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------
CheckOmittedWeb  routine
  If not omitted(pServer)
    If Not pServer &= Null
      Net:ShortInit = 1
    End
  End

UpdateStats  Routine
PopulateBannedQueue  Routine
  Data
str  StringTheory
cx   Long
  Code
  free(BannedQueue)
  str.SetValue(s_web.GetBanned())
  str.split(',')
  loop cx = 1 to str.records()
    BannedQueue.IPAddress = str.getline(cx)
    Add(BannedQueue)
  end
  display()
! ----------------------------------------------------------------------------------------
SaveSettings  Routine
  data
SettingsName        StringTheory
SettingsXML         xFileXML
  code
  SettingsName.SetValue(SettingsName.FileNameOnly(command(0),false) &'.ServerSettings.Xml')
    SettingsXML.Start()
    SettingsXML.TagCase = xf:CaseLower
    SettingsXML.Save(ServerSettings,SettingsName.GetValue(),'','ServerSettings')
! ----------------------------------------------------------------------------------------
LoadSettings  Routine
  data
SettingsName        StringTheory
SettingsXML         xFileXML
  code
  SettingsName.SetValue(SettingsName.FileNameOnly(command(0),false) &'.ServerSettings.Xml')
  If exists(SettingsName.GetValue()) = false
    rename('ServerSettings.xml',SettingsName.GetValue())
  End
  SettingsXML.Start()
  SettingsXML.TagCase = xf:CaseLower
  SettingsXML.Load(ServerSettings,SettingsName.GetValue(),'','ServerSettings')
  if set:SecurePort = 0 and set:InsecurePort = 0 then set:InsecurePort = 88.

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

!s_web    &NetWebServer
  CODE
  do CheckOmittedWeb
  If Net:ShortInit
    s_web &= pServer
  Else
    s_web &= ThisWebServer
    if ThisSessionStore &= Null  ! allows this to be set earlier to some other object.
      ThisSessionStore &= new NetSessionsQueue
    end
    if s_web.iSession &= null
      s_web.iSession &= ThisSessionStore.iNetSessions
    end
    ThisSessionStore.Server &= s_web
  End
  GlobalErrors.SetProcedureName('WebServer')
  Do LoadSettings
  If set:CertificatesFolder = '' then set:CertificatesFolder = s_web._SitesQueue.defaults.CertificatesPath.
  If set:AcmeFolder = '' then set:AcmeFolder = s_web._SitesQueue.defaults.AcmeFolderPath.
  If set:WebFolder = '' then set:WebFolder = s_web._SitesQueue.defaults.WebfolderPath.
  If set:SessionTimeout = 0 then set:SessionTimeout = 90001.
  If set:xFrameOptions = '' then set:xFrameOptions = 'sameorigin'.
  If set:AccessControlAllowOrigin = '' then set:AccessControlAllowOrigin = '*'.
  If set:ReferrerPolicy = '' then set:ReferrerPolicy = 'strict-origin-when-cross-origin'.
  If Net:ShortInit = 0
    s_web.MoveFolder(clip(set:WebFolder) & '\certificates','certificates')
    s_web._ServerIP = set:BindToIpAddress
  End
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?LogQueue
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:Accident.Open                                     ! File Accident used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Open(Window)                                        ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?LogQueue{PROP:LineHeight} = 10
                                               ! Generated by NetTalk Extension (Start)
  If Net:ShortInit = false  ! not set by DLL
    s_web.InactiveTimeout = 6000 * 5 ! 5 minutes
    s_web.SuppressErrorMsg = 1
    s_web.init()
    Get(s_web._SitesQueue,1)
    s_web._SitesQueue.defaults.CertificatesPath = set:CertificatesFolder
    s_web._SitesQueue.defaults.WebFolderPath = set:WebFolder
    s_web._SitesQueue.defaults.AcmeFolderPath = set:AcmeFolder
    s_web.acme.staging = set:staging
    s_web.SetPorts(set:InsecurePort, set:SecurePort)
    s_web.SetDomains(set:Domains,set:Passwords)
    s_web.Open()
  End
  !---------------------------------
  s_web.MaxThreads = 100
  s_web.ServerMemory.CacheSmallerThan = 1000000
  s_web.ServerMemory.MaxCache = 50000000
  s_web._SitesQueue.Defaults.WebHandlerProcName = 'WebHandler'
  s_web._SitesQueue.Defaults.DefaultPage = 'IndexPage'
  s_web._SitesQueue.Defaults.SessionExpiryAfterHS = set:SessionTimeout
  s_web._SitesQueue.Defaults.xFrameOptions = set:xFrameOptions
  s_web._SitesQueue.Defaults.Disconnected = false
  s_web._SitesQueue.Defaults.AccessControlAllowOrigin = set:AccessControlAllowOrigin
  s_web._SitesQueue.Defaults.StrictTransportSecurity = set:StrictTransportSecurity
  s_web._SitesQueue.Defaults.ContentSecurityPolicy = set:ContentSecurityPolicy
  s_web._SitesQueue.Defaults.ContentSecurityPolicyReportOnly = set:ContentSecurityPolicyReportOnly
  s_web._SitesQueue.Defaults.ReferrerPolicy = set:ReferrerPolicy
  s_web._SitesQueue.Defaults.SuggestBasic = 1
  s_web._SitesQueue.Defaults.SuggestDigest = 0
  s_web._SitesQueue.Defaults.ExternalHttps = 0
  s_web._SitesQueue.Defaults.FormLayoutMethod = Net:Grid
  s_web._SitesQueue.Defaults.BrowseLayoutMethod = Net:Grid
  s_web._SitesQueue.Defaults.ChildrenLayoutMethod = Net:Grid
  s_web._SitesQueue.Defaults.SessionLength = 30
  s_web._SitesQueue.Defaults.ChangeSessionOnLogInOut = 1
  s_web._SitesQueue.Defaults.DeleteSessionOnLogout = 0
  s_web._SitesQueue.Defaults.NoIPSpoofing = 0
  s_web.MaxPostSize = 0 * 1024 * 1024
  s_web._SitesQueue.Defaults.MaxPostSize = 0 * 1024 * 1024
  s_web._SitesQueue.Defaults.LoginPage = 'LoginForm'
  s_web._SitesQueue.Defaults.LoginPageIsControl = 1
  s_web._SitesQueue.Defaults.WebFolderPath = set:WebFolder
  If instring('\',s_web._SitesQueue.Defaults.WebFolderPath,1,1) = 0
    s_web._SitesQueue.Defaults.WebFolderPath = clip(s_web._SitesQueue.defaults.appPath) & s_web._SitesQueue.Defaults.WebFolderPath
  End
  s_web._SitesQueue.Defaults.UploadsPath = clip(s_web._SitesQueue.Defaults.WebFolderPath) & '\uploads'
  s_web._SitesQueue.Defaults.HtmlCharset = lower('utf-8')
  s_web._SitesQueue.Defaults.LocatePromptText = clip('Locate')
  s_web._SitesQueue.Defaults.LocatePromptTextPosition = clip('Locate (Position)')
  s_web._SitesQueue.Defaults.LocatePromptTextBegins = clip('Locate (Begins With)')
  s_web._SitesQueue.Defaults.LocatePromptTextContains = clip('Locate (Contains)')
  s_web._SitesQueue.Defaults.scriptsdir = 'scripts'
  s_web._SitesQueue.Defaults.ThemesDir  = 'themes'
  s_web._SitesQueue.Defaults.stylesdir  = 'styles'
  s_web.MakeFolders()
  !s_web._SitesQueue.defaults.AllowAjax = 1
  s_web._SitesQueue.defaults._CheckForParseHeader = 1         ! Check for Parse Header String
  s_web._SitesQueue.defaults._CheckForParseHeaderSize = 1000  ! Check for the Parse Header in the first x bytes
  s_web._SitesQueue.defaults._CheckParseHeader = '<!-- NetWebServer -->'
  s_web._SitesQueue.defaults.securedir = 'secure'
  s_web._SitesQueue.defaults.loggedindir = 'loggedin'
  s_web._SitesQueue.defaults.InsertPromptText = s_web.Translate('Insert')
  s_web._SitesQueue.defaults.CopyPromptText = s_web.Translate('Copy')
  s_web._SitesQueue.defaults.ChangePromptText = s_web.Translate('Change')
  s_web._SitesQueue.defaults.ViewPromptText   = s_web.Translate('View')
  s_web._SitesQueue.defaults.DeletePromptText = s_web.Translate('Delete')
  s_web._SitesQueue.defaults.RequiredText = s_web.Translate('Required')
  s_web._SitesQueue.defaults.NumericText = s_web.Translate('A Number')
  s_web._SitesQueue.defaults.MoreThanText = s_web.Translate('More than or equal to')
  s_web._SitesQueue.defaults.LessThanText = s_web.Translate('Less than or equal to')
  s_web._SitesQueue.defaults.NotZeroText = s_web.Translate('Must not be Zero or Blank')
  s_web._SitesQueue.defaults.OneOfText = s_web.Translate('Must be one of')
  s_web._SitesQueue.defaults.InListText = s_web.Translate('Must be one of')
  s_web._SitesQueue.defaults.InFileText = s_web.Translate('Must be in table')
  s_web._SitesQueue.defaults.DuplicateText = s_web.Translate('Creates Duplicate Record on')
  s_web._SitesQueue.defaults.RestrictText = s_web.Translate('Unable to Delete, Child records exist in table')
  s_web._SitesQueue.Defaults.StoreDataAs = net:StoreAsUTF8
  s_web._SitesQueue.Defaults.DatePicture = '@D6'
  s_web._SitesQueue.Defaults.PageHeaderTag = '<!-- Net:PageHeaderTag -->'
  s_web._SitesQueue.Defaults.PageFooterTag = '<!-- Net:PageFooterTag -->'
  s_web._SitesQueue.Defaults.ContentBody = 'contentbody' ! want a fixed name for ntWidth function.
  s_web._SitesQueue.Defaults.ContentBodyDivClass = 'nt-contentpanel'
  s_web._SitesQueue.Defaults.WebFormStyle = Net:Web:Tab
  s_web._SitesQueue.Defaults.DefaultDoubleClick = 1
  s_web._SitesQueue.Defaults.DefaultExport = 0
  s_web._SitesQueue.Defaults.DefaultDeletePrompt = 1
  s_web._SitesQueue.Defaults.DefaultCancelPrompt = 1
  s_web._SitesQueue.Defaults.DefaultBrowseOpenAnimation = 'effect: "slide",duration: 500'
  s_web._SitesQueue.Defaults.DefaultBrowseCloseAnimation = 'effect: "slide",duration: 500'
  s_web._SitesQueue.Defaults.DefaultFormOpenAnimation = 'effect: "slide",duration: 500'
  s_web._SitesQueue.Defaults.DefaultFormCloseAnimation = 'effect: "slide",duration: 500'
  s_web._SitesQueue.Defaults.Style.FormDiv = ' nt-form nt-width-100'
  s_web._SitesQueue.Defaults.Style.FormHeading = 'nt-header nt-form-header'
  s_web._SitesQueue.Defaults.Style.FormSubHeading = 'nt-header nt-form-header-sub'
  s_web._SitesQueue.Defaults.Style.FormTable = 'nt-form-table'
  s_web._SitesQueue.Defaults.Style.FormTableRow = 'nt-form-table-row'
  s_web._SitesQueue.Defaults.Style.FormTableCell = 'nt-form-table-cell'
  s_web._SitesQueue.Defaults.Style.FormFlex = 'nt-form-flex'
  s_web._SitesQueue.Defaults.Style.FormFlexRow = 'nt-form-flex-row'
  s_web._SitesQueue.Defaults.Style.FormFlexCell = 'nt-form-flex-cell'
  s_web._SitesQueue.Defaults.Style.FormGrid = 'nt-form-grid'
  s_web._SitesQueue.Defaults.Style.FormGridRow = 'nt-form-grid-row'
  s_web._SitesQueue.Defaults.Style.FormGridCell = 'nt-form-grid-cell'
  s_web._SitesQueue.Defaults.Style.FormPrompt = 'nt-form-div nt-prompt nt-formcell'
  s_web._SitesQueue.Defaults.Style.FormEntryDiv = 'nt-form-div nt-form-value nt-formcell'
  s_web._SitesQueue.Defaults.Style.FormButtonDiv = 'nt-form-div nt-formcell nt-left'
  s_web._SitesQueue.Defaults.Style.FormEntry = 'nt-entry'
  s_web._SitesQueue.Defaults.Style.FormSelect = ' nt-select nt-entry-select'
  s_web._SitesQueue.Defaults.Style.FormCheckBox = ' nt-flex nt-checkbox'
  s_web._SitesQueue.Defaults.Style.FormRadio = ''
  s_web._SitesQueue.Defaults.Style.FormText = ''
  s_web._SitesQueue.Defaults.Style.FormEntryRequired = 'nt-entry-required'
  s_web._SitesQueue.Defaults.Style.FormEntryReadonly = 'nt-entry-readonly'
  s_web._SitesQueue.Defaults.Style.FormEntryError = 'nt-entry-error'
  s_web._SitesQueue.Defaults.Style.FormComment = 'nt-form-div nt-comment nt-formcell'
  s_web._SitesQueue.Defaults.Style.FormCommentError = 'nt-comment-error ui-state-error ui-corner-all'
  s_web._SitesQueue.Defaults.Style.FormTabOuter = 'nt-tab-outer'
  s_web._SitesQueue.Defaults.Style.FormTabTitle = 'nt-tab-title'
  s_web._SitesQueue.Defaults.Style.FormSaveButtonSet = 'nt-flex'
  s_web._SitesQueue.Defaults.Style.ChildTable = 'nt-child-table'
  s_web._SitesQueue.Defaults.Style.ChildTableRow = 'nt-child-table-row'
  s_web._SitesQueue.Defaults.Style.ChildTableCell = 'nt-child-table-cell'
  s_web._SitesQueue.Defaults.Style.ChildFlex = 'nt-child-flex'
  s_web._SitesQueue.Defaults.Style.ChildFlexRow = 'nt-child-flex-row'
  s_web._SitesQueue.Defaults.Style.ChildFlexCell = 'nt-child-flex-cell'
  s_web._SitesQueue.Defaults.Style.ChildGrid = 'nt-child-grid'
  s_web._SitesQueue.Defaults.Style.ChildGridRow = 'nt-child-grid-row'
  s_web._SitesQueue.Defaults.Style.ChildGridCell = 'nt-child-grid-cell'
  s_web._SitesQueue.Defaults.Style.CalDiv = ''
  s_web._SitesQueue.Defaults.Style.MonthSet = 'nt-month-set'
  s_web._SitesQueue.Defaults.Style.Month = 'nt-month-big ui-widget-content ui-corner-all'
  s_web._SitesQueue.Defaults.Style.MonthSmall = 'nt-month-small ui-widget-content ui-corner-all'
  s_web._SitesQueue.Defaults.Style.MonthHeader = 'ui-widget-header ui-corner-top nt-month-header '
  s_web._SitesQueue.Defaults.Style.MonthHeading = 'nt-heading nt-month-header-center'
  s_web._SitesQueue.Defaults.Style.MonthHeaderCell = 'nt-month-header-cell nt-wide'
  s_web._SitesQueue.Defaults.Style.MonthEmptyDayCell = 'nt-monthday-empty-cell'
  s_web._SitesQueue.Defaults.Style.MonthDayCell = 'nt-monthday-cell ui-corner-all'
  s_web._SitesQueue.Defaults.Style.MonthContentCell = 'nt-content'
  s_web._SitesQueue.Defaults.Style.MonthLabelCell = 'nt-label'
  s_web._SitesQueue.Defaults.Style.MonthEmptyLabelCell = 'nt-label-empty'
  s_web._SitesQueue.Defaults.Style.MonthContentCellSmall = 'nt-hidden'
  s_web._SitesQueue.Defaults.Style.MonthLabelCellSmall = 'nt-label-small'
  s_web._SitesQueue.Defaults.Style.MonthEmptyLabelCellSmall = 'nt-label-empty-small'
  s_web._SitesQueue.Defaults.Style.FormTabInner = 'nt-tab-inner'
  s_web._SitesQueue.Defaults.Style.BrowseDiv = 'nt-browse'
  s_web._SitesQueue.Defaults.Style.BrowseFlex = 'nt-browse nt-browse-flex'
  s_web._SitesQueue.Defaults.Style.BrowseFlexBody = 'nt-browse-body nt-browse-flex-body'
  s_web._SitesQueue.Defaults.Style.BrowseFlexRow = 'nt-browse-row nt-browse-flex-row'
  s_web._SitesQueue.Defaults.Style.BrowseFlexDeletedRow = 'nt-browse-row-deleted nt-browse-flex-row-deleted'
  s_web._SitesQueue.Defaults.Style.BrowseFlexCell = 'nt-browse-cell nt-browse-flex-cell'
  
  s_web._SitesQueue.Defaults.Style.BrowseGrid = 'nt-browse nt-browse-grid'
  s_web._SitesQueue.Defaults.Style.BrowseGridBody = 'nt-browse-body nt-browse-grid-body'
  s_web._SitesQueue.Defaults.Style.BrowseGridRow = 'nt-browse-row nt-browse-grid-row'
  s_web._SitesQueue.Defaults.Style.BrowseGridDeletedRow = 'nt-browse-row-deleted nt-browse-grid-row-deleted'
  s_web._SitesQueue.Defaults.Style.BrowseGridCell = 'nt-browse-cell nt-browse-grid-cell'
  s_web._SitesQueue.Defaults.Style.BrowseTable = 'nt-browse nt-browse-table'
  s_web._SitesQueue.Defaults.Style.BrowseTableDiv = 'ui-widget'
  s_web._SitesQueue.Defaults.Style.BrowseHeader = 'nt-browse-head nt-browse-table-header'
  s_web._SitesQueue.Defaults.Style.BrowseBody = 'nt-browse-body nt-browse-table-body'
  s_web._SitesQueue.Defaults.Style.BrowseTableRow = 'nt-browse-row nt-browse-table-row'
  s_web._SitesQueue.Defaults.Style.BrowseTableCell = 'nt-browse-cell nt-browse-table-cell'
  s_web._SitesQueue.Defaults.Style.BrowseTableDeletedRow = 'nt-browse-row-deleted nt-browse-table-row-deleted'
  s_web._SitesQueue.Defaults.Style.BrowseFoot = 'nt-browse-foot nt-browse-table-foot'
  s_web._SitesQueue.Defaults.Style.BrowseFooter = ' nt-browse-footer nt-browse-table-footer'
  s_web._SitesQueue.Defaults.Style.BrowseFooterEmpty = ' nt-browse-footer-empty nt-browse-table-footer-empty'
  s_web._SitesQueue.Defaults.Style.BrowseHeading = 'nt-header nt-browse-header'
  s_web._SitesQueue.Defaults.Style.BrowseSubHeading = 'nt-header nt-browse-header-sub'
  s_web._SitesQueue.Defaults.Style.BrowseLocator = 'nt-locator'
  s_web._SitesQueue.Defaults.Style.BrowseLocateButtonSet = 'nt-flex nt-locator-button-set'
  s_web._SitesQueue.Defaults.Style.BrowseNavButtonSet = 'nt-flex nt-nav-button-set'
  s_web._SitesQueue.Defaults.Style.BrowseUpdateButtonSet = 'nt-flex nt-update-button-set'
  s_web._SitesQueue.Defaults.Style.BrowseSelectButtonSet = 'nt-flex nt-select-button-set'
  s_web._SitesQueue.Defaults.Style.BrowseHyperLinks = ''
  s_web._SitesQueue.Defaults.Style.BrowseEmpty = ' nt-browse-empty'
  s_web._SitesQueue.Defaults.Style.BrowseEntry = 'nt-browse-entry'
  s_web._SitesQueue.Defaults.Style.BrowseText = 'nt-browse-entry'
  s_web._SitesQueue.Defaults.Style.BrowseDate = 'nt-browse-entry'
  s_web._SitesQueue.Defaults.Style.BrowseDrop = 'nt-browse-entry'
  s_web._SitesQueue.Defaults.Style.BrowseDropOption = 'nt-browse-entry'
  s_web._SitesQueue.Defaults.Style.BrowseCheck = 'nt-browse-entry'
  s_web._SitesQueue.Defaults.Style.BrowseCheckPlain = 'nt-browse-entry nt-naked-checkbox'
  s_web._SitesQueue.Defaults.Style.BrowseOtherButtonWithText = ''
  s_web._SitesQueue.Defaults.Style.BrowseOtherButtonWithoutText = ''
  s_web._SitesQueue.Defaults.Style.FormOtherButtonWithText = ''
  s_web._SitesQueue.Defaults.Style.FormOtherButtonWithoutText = ''
  s_web._SitesQueue.Defaults.HtmlClass = 'nt-html'
  s_web._SitesQueue.Defaults.BodyClass = 'nt-body'
  s_web._SitesQueue.Defaults.BodyDivClass = 'nt-body-div'
  s_web._SitesQueue.Defaults.BusyClass = 'nt-busy'
  s_web._SitesQueue.Defaults.BusyImage = '/images/_busy.gif'
  s_web._SitesQueue.Defaults.SyncOffImage = '/images/sync-off.png'
  s_web._SitesQueue.Defaults.MessageClass = 'nt-alert ui-state-error ui-corner-all'
  s_web._SitesQueue.Defaults.MapProvider = Net:Esri:WorldStreetMap
  s_web._SitesQueue.Defaults.MapId_HERE_ApiKey = 'U1501BJMZ_jJorskAb_UK3i8dghLJiz7JW-Ult18K8w'
  s_web._SitesQueue.Defaults.MapDefaultMarker = ''
  s_web._SitesQueue.Defaults.HeaderBackButton = 0
  s_web._SitesQueue.Defaults.HeaderBackButtonIcon = 'back-w'
  s_web._SitesQueue.Defaults.HeaderBackButtonCSS = ' ui-icons-32'
  s_web._SitesQueue.Defaults.DefaultHTMLEditor = net:HTMLNone
  s_web._SitesQueue.Defaults.UploadButton.Name = 'upload_btn'
  s_web._SitesQueue.Defaults.UploadButton.TextValue = clip('Upload') !s_web.Translate('Upload',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.UploadButton.Class = ''
  s_web._SitesQueue.Defaults.UploadButton.ToolTip = clip('Click here to Upload the file') !s_web.Translate('Click here to Upload the file')
  s_web._SitesQueue.Defaults.UploadButton.JsIcon = ''
  s_web._SitesQueue.Defaults.LookupButton.Name = 'lookup_btn'
  s_web._SitesQueue.Defaults.LookupButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.LookupButton.Class = 'nt-lookup-button nt-small-button'
  s_web._SitesQueue.Defaults.LookupButton.ToolTip = clip('Click here to Search for a value') !s_web.Translate('Click here to Search for a value')
  s_web._SitesQueue.Defaults.LookupButton.JsIcon = 'help'
  s_web._SitesQueue.Defaults.LookupButton.PopupHeader = 'Lookup'
  s_web._SitesQueue.Defaults.SaveButton.Name = 'save_btn'
  s_web._SitesQueue.Defaults.SaveButton.TextValue = clip('Save') !s_web.Translate('Save',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SaveButton.Class = 'nt-save-button'
  s_web._SitesQueue.Defaults.SaveButton.ToolTip = clip('Click on this to Save the form') !s_web.Translate('Click on this to Save the form')
  s_web._SitesQueue.Defaults.SaveButton.JsIcon = 'check'
  s_web._SitesQueue.Defaults.CancelButton.Name = 'cancel_btn'
  s_web._SitesQueue.Defaults.CancelButton.TextValue = clip('Cancel') !s_web.Translate('Cancel',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.CancelButton.Class = 'nt-cancel-button'
  s_web._SitesQueue.Defaults.CancelButton.ToolTip = clip('Click on this to Cancel the form') !s_web.Translate('Click on this to Cancel the form')
  s_web._SitesQueue.Defaults.CancelButton.JsIcon = 'cancel'
  s_web._SitesQueue.Defaults.DeletefButton.Name = 'deletef_btn'
  s_web._SitesQueue.Defaults.DeletefButton.TextValue = clip('Delete') !s_web.Translate('Delete',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.DeletefButton.Class = 'nt-deletef-button'
  s_web._SitesQueue.Defaults.DeletefButton.ToolTip = clip('Click here to Delete this record') !s_web.Translate('Click here to Delete this record')
  s_web._SitesQueue.Defaults.DeletefButton.JsIcon = 'trash'
  s_web._SitesQueue.Defaults.CloseButton.Name = 'close_btn'
  s_web._SitesQueue.Defaults.CloseButton.TextValue = clip('Close') !s_web.Translate('Close',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.CloseButton.Class = 'nt-close-button'
  s_web._SitesQueue.Defaults.CloseButton.ToolTip = clip('Click here to Close this form') !s_web.Translate('Click here to Close this form')
  s_web._SitesQueue.Defaults.CloseButton.JsIcon = 'check'
  s_web._SitesQueue.Defaults.InsertButton.Name = 'insert_btn'
  s_web._SitesQueue.Defaults.InsertButton.TextValue = clip('Insert') !s_web.Translate('Insert',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.InsertButton.Class = 'nt-insert-button'
  s_web._SitesQueue.Defaults.InsertButton.ToolTip = clip('Click here to Insert a new record') !s_web.Translate('Click here to Insert a new record')
  s_web._SitesQueue.Defaults.InsertButton.JsIcon = 'plus'
  s_web._SitesQueue.Defaults.InsertButton.PopupHeader = 'Insert'
  s_web._SitesQueue.Defaults.ChangeButton.Name = 'change_btn'
  s_web._SitesQueue.Defaults.ChangeButton.TextValue = clip('Change') !s_web.Translate('Change',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.ChangeButton.Class = 'nt-change-button'
  s_web._SitesQueue.Defaults.ChangeButton.ToolTip = clip('Click here to Change the highlighted record') !s_web.Translate('Click here to Change the highlighted record')
  s_web._SitesQueue.Defaults.ChangeButton.JsIcon = 'pencil'
  s_web._SitesQueue.Defaults.ChangeButton.PopupHeader = 'Change'
  s_web._SitesQueue.Defaults.ViewButton.Name = 'view_btn'
  s_web._SitesQueue.Defaults.ViewButton.TextValue = clip('View') !s_web.Translate('View',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.ViewButton.Class = 'nt-view-button'
  s_web._SitesQueue.Defaults.ViewButton.ToolTip = clip('Click here to view details of the highlighted record') !s_web.Translate('Click here to view details of the highlighted record')
  s_web._SitesQueue.Defaults.ViewButton.JsIcon = 'search'
  s_web._SitesQueue.Defaults.ViewButton.PopupHeader = 'View'
  s_web._SitesQueue.Defaults.DeletebButton.Name = 'deleteb_btn'
  s_web._SitesQueue.Defaults.DeletebButton.TextValue = clip('Delete') !s_web.Translate('Delete',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.DeletebButton.Class = 'nt-deleteb-button'
  s_web._SitesQueue.Defaults.DeletebButton.ToolTip = clip('Click here to Delete the highlighted record') !s_web.Translate('Click here to Delete the highlighted record')
  s_web._SitesQueue.Defaults.DeletebButton.JsIcon = 'trash'
  s_web._SitesQueue.Defaults.DeletebButton.PopupHeader = 'Delete'
  s_web._SitesQueue.Defaults.SelectButton.Name = 'select_btn'
  s_web._SitesQueue.Defaults.SelectButton.TextValue = clip('Select') !s_web.Translate('Select',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SelectButton.Class = 'nt-select-button'
  s_web._SitesQueue.Defaults.SelectButton.ToolTip = clip('Click here to Select the highlighted record') !s_web.Translate('Click here to Select the highlighted record')
  s_web._SitesQueue.Defaults.SelectButton.JsIcon = 'check'
  s_web._SitesQueue.Defaults.BrowseCancelButton.Name = 'browsecancel_btn'
  s_web._SitesQueue.Defaults.BrowseCancelButton.TextValue = clip('Cancel') !s_web.Translate('Cancel',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.BrowseCancelButton.Class = 'nt-cancel-button'
  s_web._SitesQueue.Defaults.BrowseCancelButton.ToolTip = clip('Click here to return without selecting anything') !s_web.Translate('Click here to return without selecting anything')
  s_web._SitesQueue.Defaults.BrowseCancelButton.JsIcon = 'cancel'
  s_web._SitesQueue.Defaults.BrowseCloseButton.Name = 'browseclose_btn'
  s_web._SitesQueue.Defaults.BrowseCloseButton.TextValue = clip('Close') !s_web.Translate('Close',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.BrowseCloseButton.Class = 'nt-close-button'
  s_web._SitesQueue.Defaults.BrowseCloseButton.ToolTip = clip('Click here to Close this browse') !s_web.Translate('Click here to Close this browse')
  s_web._SitesQueue.Defaults.BrowseCloseButton.JsIcon = 'check'
  s_web._SitesQueue.Defaults.SmallInsertButton.Name = 'insert_btn'
  s_web._SitesQueue.Defaults.SmallInsertButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallInsertButton.Class = 'nt-insert-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallInsertButton.ToolTip = clip('Click here to Insert a new record') !s_web.Translate('Click here to Insert a new record')
  s_web._SitesQueue.Defaults.SmallInsertButton.JsIcon = 'plus'
  s_web._SitesQueue.Defaults.SmallInsertButton.PopupHeader = 'Insert'
  s_web._SitesQueue.Defaults.SmallChangeButton.Name = 'change_btn'
  s_web._SitesQueue.Defaults.SmallChangeButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallChangeButton.Class = 'nt-change-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallChangeButton.ToolTip = clip('Click here to Change this record') !s_web.Translate('Click here to Change this record')
  s_web._SitesQueue.Defaults.SmallChangeButton.JsIcon = 'pencil'
  s_web._SitesQueue.Defaults.SmallChangeButton.PopupHeader = 'Change'
  s_web._SitesQueue.Defaults.SmallViewButton.Name = 'view_btn'
  s_web._SitesQueue.Defaults.SmallViewButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallViewButton.Class = 'nt-view-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallViewButton.ToolTip = clip('Click here to View details of this record') !s_web.Translate('Click here to View details of this record')
  s_web._SitesQueue.Defaults.SmallViewButton.JsIcon = 'search'
  s_web._SitesQueue.Defaults.SmallViewButton.PopupHeader = 'View'
  s_web._SitesQueue.Defaults.SmallDeleteButton.Name = 'deleteb_btn'
  s_web._SitesQueue.Defaults.SmallDeleteButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallDeleteButton.Class = 'nt-deleteb-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallDeleteButton.ToolTip = clip('Click here to Delete this record') !s_web.Translate('Click here to Delete this record')
  s_web._SitesQueue.Defaults.SmallDeleteButton.JsIcon = 'trash'
  s_web._SitesQueue.Defaults.SmallDeleteButton.PopupHeader = 'Delete'
  s_web._SitesQueue.Defaults.SmallSelectButton.Name = 'select_btn'
  s_web._SitesQueue.Defaults.SmallSelectButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallSelectButton.Class = 'nt-select-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallSelectButton.ToolTip = clip('Click here to Select this record') !s_web.Translate('Click here to Select this record')
  s_web._SitesQueue.Defaults.SmallSelectButton.JsIcon = 'check'
  s_web._SitesQueue.Defaults.LocateButton.Name = 'locate_btn'
  s_web._SitesQueue.Defaults.LocateButton.TextValue = clip('Search') !s_web.Translate('Search',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.LocateButton.Class = 'nt-locate-button'
  s_web._SitesQueue.Defaults.LocateButton.ToolTip = clip('Click here to start the Search') !s_web.Translate('Click here to start the Search')
  s_web._SitesQueue.Defaults.LocateButton.JsIcon = 'lightbulb'
  s_web._SitesQueue.Defaults.FirstButton.Name = 'first_btn'
  s_web._SitesQueue.Defaults.FirstButton.TextValue = clip('First') !s_web.Translate('First',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.FirstButton.Class = 'nt-first-button'
  s_web._SitesQueue.Defaults.FirstButton.ToolTip = clip('Click here to go to the First page in the list') !s_web.Translate('Click here to go to the First page in the list')
  s_web._SitesQueue.Defaults.FirstButton.JsIcon = 'arrowthickstop-1-w'
  s_web._SitesQueue.Defaults.PreviousButton.Name = 'previous_btn'
  s_web._SitesQueue.Defaults.PreviousButton.TextValue = clip('Previous') !s_web.Translate('Previous',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.PreviousButton.Class = 'nt-previous-button'
  s_web._SitesQueue.Defaults.PreviousButton.ToolTip = clip('Click here to go to the Previous page in the list') !s_web.Translate('Click here to go to the Previous page in the list')
  s_web._SitesQueue.Defaults.PreviousButton.JsIcon = 'arrowthick-1-w'
  s_web._SitesQueue.Defaults.NextButton.Name = 'next_btn'
  s_web._SitesQueue.Defaults.NextButton.TextValue = clip('Next') !s_web.Translate('Next',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.NextButton.Class = 'nt-next-button'
  s_web._SitesQueue.Defaults.NextButton.ToolTip = clip('Click here to go to the Next page in the list') !s_web.Translate('Click here to go to the Next page in the list')
  s_web._SitesQueue.Defaults.NextButton.JsIcon = 'arrowthick-1-e'
  s_web._SitesQueue.Defaults.LastButton.Name = 'last_btn'
  s_web._SitesQueue.Defaults.LastButton.TextValue = clip('Last') !s_web.Translate('Last',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.LastButton.Class = 'nt-last-button'
  s_web._SitesQueue.Defaults.LastButton.ToolTip = clip('Click here to go to the Last page in the list') !s_web.Translate('Click here to go to the Last page in the list')
  s_web._SitesQueue.Defaults.LastButton.JsIcon = 'arrowthickstop-1-e'
  s_web._SitesQueue.Defaults.PrintButton.Name = 'print_btn'
  s_web._SitesQueue.Defaults.PrintButton.TextValue = clip('Print') !s_web.Translate('Print',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.PrintButton.Class = 'nt-print-button'
  s_web._SitesQueue.Defaults.PrintButton.ToolTip = clip('Click here to Print this page') !s_web.Translate('Click here to Print this page')
  s_web._SitesQueue.Defaults.PrintButton.JsIcon = 'print'
  s_web._SitesQueue.Defaults.StartButton.Name = 'start_btn'
  s_web._SitesQueue.Defaults.StartButton.TextValue = clip('Start') !s_web.Translate('Start',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.StartButton.Class = 'nt-start-button'
  s_web._SitesQueue.Defaults.StartButton.ToolTip = clip('Click here to Start the report') !s_web.Translate('Click here to Start the report')
  s_web._SitesQueue.Defaults.StartButton.JsIcon = 'check'
  s_web._SitesQueue.Defaults.DateLookupButton.Name = 'lookup_btn'
  s_web._SitesQueue.Defaults.DateLookupButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.DateLookupButton.Class = 'nt-small-button nt-lookup-button'
  s_web._SitesQueue.Defaults.DateLookupButton.ToolTip = clip('Click here to select a date') !s_web.Translate('Click here to select a date')
  s_web._SitesQueue.Defaults.DateLookupButton.JsIcon = 'help'
  s_web._SitesQueue.Defaults.WizPreviousButton.Name = 'wizprevious_btn'
  s_web._SitesQueue.Defaults.WizPreviousButton.TextValue = clip('Previous') !s_web.Translate('Previous',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.WizPreviousButton.Class = 'nt-wizprevious-button'
  s_web._SitesQueue.Defaults.WizPreviousButton.ToolTip = clip('Click here to go back to the Previous step') !s_web.Translate('Click here to go back to the Previous step')
  s_web._SitesQueue.Defaults.WizPreviousButton.JsIcon = 'arrowthick-1-w'
  s_web._SitesQueue.Defaults.WizNextButton.Name = 'wiznext_btn'
  s_web._SitesQueue.Defaults.WizNextButton.TextValue = clip('Next') !s_web.Translate('Next',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.WizNextButton.Class = 'nt-wiznext-button'
  s_web._SitesQueue.Defaults.WizNextButton.ToolTip = clip('Click here to go to the Next step') !s_web.Translate('Click here to go to the Next step')
  s_web._SitesQueue.Defaults.WizNextButton.JsIcon = 'arrowthick-1-e'
  s_web._SitesQueue.Defaults.SmallOtherButton.Name = 'other_btn'
  s_web._SitesQueue.Defaults.SmallOtherButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallOtherButton.Class = 'nt-small-button'
  s_web._SitesQueue.Defaults.SmallOtherButton.ToolTip = clip('') !s_web.Translate('')
  s_web._SitesQueue.Defaults.SmallOtherButton.JsIcon = ''
  s_web._SitesQueue.Defaults.SmallPrintButton.Name = 'print_btn'
  s_web._SitesQueue.Defaults.SmallPrintButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallPrintButton.Class = 'nt-print-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallPrintButton.ToolTip = clip('Click here to print this record') !s_web.Translate('Click here to print this record')
  s_web._SitesQueue.Defaults.SmallPrintButton.JsIcon = 'print'
  s_web._SitesQueue.Defaults.CopyButton.Name = 'copy_btn'
  s_web._SitesQueue.Defaults.CopyButton.TextValue = clip('Copy') !s_web.Translate('Copy',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.CopyButton.Class = 'nt-copy-button'
  s_web._SitesQueue.Defaults.CopyButton.ToolTip = clip('Click here to copy the highlighted record') !s_web.Translate('Click here to copy the highlighted record')
  s_web._SitesQueue.Defaults.CopyButton.JsIcon = 'copy'
  s_web._SitesQueue.Defaults.CopyButton.PopupHeader = 'Copy'
  s_web._SitesQueue.Defaults.SmallCopyButton.Name = 'copy_btn'
  s_web._SitesQueue.Defaults.SmallCopyButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallCopyButton.Class = 'nt-copy-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallCopyButton.ToolTip = clip('Click here to copy this record') !s_web.Translate('Click here to copy this record')
  s_web._SitesQueue.Defaults.SmallCopyButton.JsIcon = 'copy'
  s_web._SitesQueue.Defaults.SmallCopyButton.PopupHeader = 'Copy'
  s_web._SitesQueue.Defaults.ClearButton.Name = 'clear_btn'
  s_web._SitesQueue.Defaults.ClearButton.TextValue = clip('Clear') !s_web.Translate('Clear',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.ClearButton.Class = 'nt-clear-button'
  s_web._SitesQueue.Defaults.ClearButton.ToolTip = clip('Click here to clear the locator') !s_web.Translate('Click here to clear the locator')
  s_web._SitesQueue.Defaults.ClearButton.JsIcon = 'arrowrefresh-1-w'
  s_web._SitesQueue.Defaults.LogoutButton.Name = 'logout_btn'
  s_web._SitesQueue.Defaults.LogoutButton.TextValue = clip('Logout') !s_web.Translate('Logout',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.LogoutButton.Class = 'nt-logout-button'
  s_web._SitesQueue.Defaults.LogoutButton.ToolTip = clip('Click here to logout') !s_web.Translate('Click here to logout')
  s_web._SitesQueue.Defaults.LogoutButton.JsIcon = 'locked'
  s_web._SitesQueue.Defaults.AddFileButton.Name = 'addfile_btn'
  s_web._SitesQueue.Defaults.AddFileButton.TextValue = clip('Add File') !s_web.Translate('Add File',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.AddFileButton.Class = 'nt-button nt-insert-button'
  s_web._SitesQueue.Defaults.AddFileButton.ToolTip = clip('Click here to add files') !s_web.Translate('Click here to add files')
  s_web._SitesQueue.Defaults.AddFileButton.JsIcon = 'plus'
  s_web._SitesQueue.Defaults.ClearFileButton.Name = 'clearfile_btn'
  s_web._SitesQueue.Defaults.ClearFileButton.TextValue = clip('Clear') !s_web.Translate('Clear',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.ClearFileButton.Class = 'nt-button nt-deletef-button'
  s_web._SitesQueue.Defaults.ClearFileButton.ToolTip = clip('Click here to clear the file list') !s_web.Translate('Click here to clear the file list')
  s_web._SitesQueue.Defaults.ClearFileButton.JsIcon = 'trash'
  s_web._SitesQueue.Defaults.StartFileButton.Name = 'startfile_btn'
  s_web._SitesQueue.Defaults.StartFileButton.TextValue = clip('Start') !s_web.Translate('Start',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.StartFileButton.Class = 'nt-button nt-save-button'
  s_web._SitesQueue.Defaults.StartFileButton.ToolTip = clip('Click here to start the upload') !s_web.Translate('Click here to start the upload')
  s_web._SitesQueue.Defaults.StartFileButton.JsIcon = 'play'
  s_web._SitesQueue.Defaults.CancelFileButton.Name = 'cancelfile_btn'
  s_web._SitesQueue.Defaults.CancelFileButton.TextValue = clip('Cancel') !s_web.Translate('Cancel',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.CancelFileButton.Class = 'nt-cancel-button'
  s_web._SitesQueue.Defaults.CancelFileButton.ToolTip = clip('Click here to cancel the upload') !s_web.Translate('Click here to cancel the upload')
  s_web._SitesQueue.Defaults.CancelFileButton.JsIcon = 'cancel'
  s_web._SitesQueue.Defaults.RemoveFileButton.Name = 'removefile_btn'
  s_web._SitesQueue.Defaults.RemoveFileButton.TextValue = clip('Remove') !s_web.Translate('Remove',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.RemoveFileButton.Class = 'nt-deletef-button'
  s_web._SitesQueue.Defaults.RemoveFileButton.ToolTip = clip('Click here to remove this file from the list') !s_web.Translate('Click here to remove this file from the list')
  s_web._SitesQueue.Defaults.RemoveFileButton.JsIcon = 'trash'
  s_web._SitesQueue.Defaults.ExportButton.Name = 'export_btn'
  s_web._SitesQueue.Defaults.ExportButton.TextValue = clip('Export') !s_web.Translate('Export',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.ExportButton.Class = 'nt-export-button'
  s_web._SitesQueue.Defaults.ExportButton.ToolTip = clip('Click here to export the data in this browse') !s_web.Translate('Click here to export the data in this browse')
  s_web._SitesQueue.Defaults.ExportButton.JsIcon = 'arrowreturnthick-1-e'
  s_web._SitesQueue.Defaults.SmallMoveupButton.Name = 'moveup_btn'
  s_web._SitesQueue.Defaults.SmallMoveupButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallMoveupButton.Class = 'nt-moveup-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallMoveupButton.ToolTip = clip('Click here to move the row up') !s_web.Translate('Click here to move the row up')
  s_web._SitesQueue.Defaults.SmallMoveupButton.JsIcon = 'triangle-1-n'
  s_web._SitesQueue.Defaults.SmallMovedownButton.Name = 'moveup_btn'
  s_web._SitesQueue.Defaults.SmallMovedownButton.TextValue = clip('') !s_web.Translate('',Net:HtmlOk) ! button text will be cleaned later on.
  s_web._SitesQueue.Defaults.SmallMovedownButton.Class = 'nt-movedown-button nt-small-button'
  s_web._SitesQueue.Defaults.SmallMovedownButton.ToolTip = clip('Click here to move the row down') !s_web.Translate('Click here to move the row down')
  s_web._SitesQueue.Defaults.SmallMovedownButton.JsIcon = 'triangle-1-s'
  s_web._SitesQueue.Defaults.PreCompressed = 0
  s_web._SitesQueue.Defaults.CompressStatic = 0
  s_web._SitesQueue.Defaults.CompressDynamic = 0
  s_web._SitesQueue.Defaults.AutoCheckCache = 0
  s_web._SitesQueue.Defaults.ResourceVersion = 1
  s_web._SitesQueue.Defaults.FrontLoaded       = 0
  s_web._SitesQueue.Defaults.NoJavaScriptCheck = 0
  s_web._SitesQueue.Defaults.NoScreenSizeCheck = 0
  s_web._SitesQueue.Defaults.MultiTab = false
  s_web._SitesQueue.Defaults.ReuseConnections  = 0 ! 0
  s_web._SitesQueue.Defaults.PinchToZoom  = true
  s_web._SitesQueue.Defaults.HasServiceWorker = false
  s_web._SitesQueue.Defaults.themeColor  = 'white'
  IF(false)
    s_web._SitesQueue.Defaults.HtmlCommonScripts = |
      s_web.AddScript('all.js') &|
      s_web.AddScript('/redactor/redactor.min.js') &|
      ''
  Else
    s_web._SitesQueue.Defaults.HtmlCommonScripts = |
      s_web.AddScript('modernizr.custom.js') &|
      s_web.AddScript('jquery-3.6.0.min.js') &|
      s_web.AddScript('jquery-ui-1.13.2.custom.min.js') &|
      s_web.AddScript('jquery.form.js') &|
      s_web.AddScript('jquery.nt-form.js') &|
      s_web.AddScript('jquery.nt-menu.js') &|
      s_web.AddScript('jquery.nt-wiz.js') &|
      s_web.AddScript('jquery.metadata.js') &|
      s_web.AddScript('jquery.nt-color.js') &|
      s_web.AddScript('jquery.nt-dialog.js') &|
      s_web.AddScript('jquery.media.js') &|
      s_web.AddScript('leaflet.js') &|
      s_web.AddScript('leaflet.markercluster.js') &|
      s_web.AddScript('jquery.nt-maps.js') &|
      s_web.AddScript('netweb.js') &|
      s_web.AddScript('jquery.nt-session.js') &|
      s_web.AddScript('jquery.nt-browse.js') &|
      s_web.AddScript('jcanvas.js') &|
      s_web.AddScript('jquery.nt-cal.js') &|
      s_web.AddScript('jquery.ad-gallery.js') &|
      s_web.AddScript('jquery.iframe-transport.js') &|
      s_web.AddScript('jquery.fileupload.js') &|
      s_web.AddScript('jquery.nt-upload.js') &|
      s_web.AddScript('/redactor/redactor.js') &|
      s_web.AddScript('/redactor/_plugins/alignment/alignment.js') &|
      s_web.AddScript('/redactor/_plugins/fontfamily/fontfamily.js') &|
      s_web.AddScript('/redactor/_plugins/fontcolor/fontcolor.js') &|
      s_web.AddScript('/redactor/_plugins/fontsize/fontsize.js') &|
    ''
  End
  s_web._SitesQueue.Defaults.HtmlMSIE6Scripts = |
    s_web.AddScript('msie6.js') &|
  ''
  s_web.AddGoogleFont('Open Sans',1,1,0,0,1,0,,,)
  s_web._SitesQueue.Defaults.DefaultTheme = 'Base'
  
  IF(false)
    s_web._SitesQueue.Defaults.HtmlCommonStyles = |
      s_web.AddManifest() &|
      s_web.AddStyle(clip('Base') & '/theme.css',true) &|
      s_web.AddStyle('/redactor/redactor.min.css') &|
      ''
  Else
    s_web._SitesQueue.Defaults.HtmlCommonStyles = |
      s_web.AddManifest() &|
      s_web.AddStyle(clip('Base') & '/nt-theme.css',true) & |
      s_web.AddStyle('jquery-ui.structure.css') &|
      s_web.AddStyle(clip('Base') & '/jquery-ui.theme.css',true) & |
      s_web.AddStyle('jquery-nt-color.css') &|
      s_web.AddStyle('jquery-nt-menu.css') &|
      s_web.AddStyle('jquery-nt-cal.css') &|
      s_web.AddStyle('jquery.ad-gallery.css') &|
      s_web.AddStyle('jquery.fileupload-ui.css') &|
      s_web.AddStyle('leaflet.css') &|
      s_web.AddStyle('leaflet.markercluster.css') &|
      s_web.AddStyle('netweb.css') &|
      s_web.AddStyle('/redactor/redactor.css') &|
      s_web.AddStyle('nettalk-grid.css') &|
      s_web.AddStyle(clip('Base') & '/nettalk-ui.css',true) & |
    ''
  End
  
  s_web._SitesQueue.Defaults.HtmlMSIE6Styles = |
    s_web.AddStyle('msie6.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlMSIE7Styles = |
    s_web.AddStyle('msie7.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlMSIE8Styles = |
    s_web.AddStyle('msie.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlMSIE9Styles = |
    s_web.AddStyle('msie.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlMSIE10Styles = |
    s_web.AddStyle('msie.css') &|
    ''
  s_web._SitesQueue.Defaults.HtmlMSIE11Styles = |
    s_web.AddStyle('msie.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlEdgeStyles = |
    s_web.AddStyle('edge.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlFireFoxStyles = |
    s_web.AddStyle('firefox.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlSafariStyles = |
    s_web.AddStyle('safari.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlChromeStyles = |
    s_web.AddStyle('chrome.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlOperaStyles = |
    s_web.AddStyle('opera.css') &|
    ''
  
  s_web._SitesQueue.Defaults.HtmlMozillaStyles = |
    s_web.AddStyle('firefox.css') &|
    ''
  
  Put(s_web._SitesQueue)
  If Net:ShortInit
    ReturnValue = Level:Notify
    Return ReturnValue                    ! Short Init Ends Here
  End
  s_web.iSession.load()
  
  !--------------------------------------------------------------
  if ThisWebServer.error <> 0
    ! Put code in here to handle if the object does not initialise properly
  end
  Do DefineListboxStyle
  If Net:ShortInit = 0
    s_web.acme.LogControl = ?LogText
    s_web.acme.Staging = set:Staging
  End
  INIMgr.Fetch('WebServer',Window)                         ! Restore window settings from non-volatile store
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
    s_web.iSession.Save()
  ThisWebServer.Kill()                              ! Generated by NetTalk Extension
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Accident.Close
  END
  IF SELF.Opened
    INIMgr.Update('WebServer',Window)                      ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?BUTTON1
      Access:Accident.Open()
      Access:Accident.UseFile()
      loop 20 TIMES
        Acc:Latitude = (-34038 + random(1,20)) / 1000
        Acc:Longitude = (18471 + random(1,20)) / 1000
        Acc:Guid = glo:st.Random(16)
        Acc:Type = random(1,5)
        Acc:Date = today() - random(1,365)
        Acc:Time = random(1,8640000)
        Acc:Description = choose(Acc:Type,'Car','Bike','Bus','Truck','Pedestrian')
        
        Access:Accident.Insert()
      END      
      
      loop 20 TIMES
        Acc:Latitude = (-34038 + random(50,70)) / 1000
        Acc:Longitude = (18471 + random(-30,-40)) / 1000
        Acc:Guid = glo:st.Random(16)
        Acc:Type = random(1,5)
        Acc:Date = today() - random(1,365)
        Acc:Time = random(1,8640000)
        Acc:Description = choose(Acc:Type,'Car','Bike','Bus','Truck','Pedestrian')
        Access:Accident.Insert()
      END      
      
      loop 20 TIMES
        Acc:Latitude = (-34038 + random(-20,20)) / 1000
        Acc:Longitude = (18471 + random(-20,20)) / 1000
        Acc:Guid = glo:st.Random(16)
        Acc:Type = random(1,5)
        Acc:Date = today() - random(1,365)
        Acc:Time = random(1,8640000)
        Acc:Description = choose(Acc:Type,'Car','Bike','Bus','Truck','Pedestrian')
        Access:Accident.Insert()
      END      
      
      loop 20 TIMES
        Acc:Latitude = (-34038 + random(-30,80)) / 1000
        Acc:Longitude = (18471 + random(-30,80)) / 1000
        Acc:Guid = glo:st.Random(16)
        Acc:Type = random(1,5)
        Acc:Date = today() - random(1,365)
        Acc:Time = random(1,8640000)
        Acc:Description = choose(Acc:Type,'Car','Bike','Bus','Truck','Pedestrian')
        Access:Accident.Insert()
      END      
      
      Access:Accident.Close()
    END
  ReturnValue = PARENT.TakeAccepted()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    ThisWebServer.TakeEvent()                 ! Generated by NetTalk Extension
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWebServer.AddLog PROCEDURE(FILE p_File,*String p_Field,*String p_Name,String p_DataString,<String p_ip>)

  !-----------------------------------------------------------------------------
  ! This method is called from AddLog PROCEDURE(String p_Data,<string p_ip>) to save to a disk file
  !-----------------------------------------------------------------------------

  CODE
  PARENT.AddLog(p_File,p_Field,p_Name,p_DataString,p_ip)


ThisWebServer.AddLog PROCEDURE(String p_Data,<string p_ip>)

  !-----------------------------------------------------------------------------
  ! This method is called before the request has been processed.
  ! Code to add to the on-screen log is added here. If logging to disk the call is made from here.
  ! For POSTs this method is called twice, once with the header and once with the whole request.
  !-----------------------------------------------------------------------------

  CODE
    self._wait()
    !! Log To Screen
    If web:EnableLogging > 0
      clear(LogQueue)
      if not omitted(p_ip)
        LogQueue.Port = p_ip
      else
        LogQueue.Port = Self.Port
      end
      LogQueue.Date = today()
      LogQueue.Time = clock()
      LogQueue.Socket = self.packet.SockID
      LogQueue.Thread = 0
      LogQueue.Desc = p_Data
      Add(LogQueue,1)
      Loop While Records(LogQueue) > 500
        Get(LogQueue,501)
        Delete(LogQueue)
      End
    End
    self._release()
  PARENT.AddLog(p_Data,p_ip)


ThisWebServer.StartNewThread PROCEDURE(NetWebServerRequestDataType p_RequestData)

StartNewPool   Long
PoolWaiting    Long
Index          Long
!loc:RequestData    Group(NetWebServerRequestDataType).
!loc:OverString     String(size(loc:RequestData)),over(loc:RequestData)

  CODE
    loc:RequestData :=: p_RequestData
    If (self.performance.NumberOfThreads >= self.MaxThreads and self.MaxThreads > 0) or loc:shuttingDown
        if loc:RequestData.RequestMethodType <> NetWebServer_DELETESESSION and PoolWaiting = 0
          if not self.WebSocketServer &= null and self.WebSocketServer.IsWebSocket(self.packet.SockID)
            ! do not send invalid reply, it's a malformed packet in the wss protocol.
          else
            self.SendError(503,'Server Busy','Server Busy, try again shortly. [TH=' & self.performance.NumberOfThreads & '] [MT]=' & self.MaxThreads & '] LSD==[' & loc:shuttingDown & ']')
          end
          self._PerfEndThread(0,0,503)  ! Errors are counted, but otherwise not included in stats
          do UpdateStats
          dispose(p_RequestData.DataString)
        end
      return
    End
    web:PagesServed = self._PagesServed + 1
    if p_RequestData.DataStringLen >= 4
      case (upper(p_RequestData.DataString[1 : 4]))
      of 'POST' orof 'PUT '
        web:LastPost = p_RequestData.DataString[1 : p_RequestData.DataStringLen]
        display (?web:LastPost)
      of 'GET '
        web:LastGet = p_RequestData.DataString[1 : p_RequestData.DataStringLen]
        display (?web:LastGet)
      else
        web:LastGet = p_RequestData.DataString[1 : p_RequestData.DataStringLen]
        display (?web:LastGet)
      end
    end
    self._PerfStartThread()
    self.NewThread = START (WebHandler, 35000, loc:OverString)
    RESUME(self.NewThread)
    do UpdateStats
      !! log thread number to screen
      Get(LogQueue,1)
      LogQueue.Thread = self.NewThread
      Put(LogQueue)
    RETURN ! Don't call parent
  PARENT.StartNewThread(p_RequestData)


ThisWebServer.TakeEvent PROCEDURE


  CODE
    if event() = Event:Accepted and field() = ?ClearStatsButton
      clear(self.performance)
      self.Performance.StartDate = today()
      self.Performance.StartTime = clock()
    End
    WebPerformance = self.Performance ! performance monitoring control template
    case Event()
    of Event:Accepted
      case Field()
      of ?Clear
        Free(LogQueue)
        web:LastGet = ''
        web:LastPost = ''
        display()
      End
    End
    case Event()
    of Event:Accepted
      case Field()
      of ?set:InsecurePort          orof ?set:SecurePort    orof ?set:AccountName
      orof ?set:CertificatesFolder  orof ?set:Domains       orof ?set:BindToIPAddress
      orof ?set:WebFolder           orof ?set:AcmeFolder    orof ?set:Staging
      orof ?set:SessionTimeout      orof ?set:xFrameOptions orof ?set:AccessControlAllowOrigin
      orof ?set:StrictTransportSecurity                     orof ?set:ContentSecurityPolicy
      orof ?set:ContentSecurityPolicyReportOnly             orof ?set:ReferrerPolicy
        do SaveSettings
      End
      case Field()
      of ?set:InsecurePort
      orof ?set:SecurePort
        s_web.SetPorts(set:InsecurePort,set:SecurePort) ! will restart if necessary
      of ?set:AccountName
      of ?set:WebFolder
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.WebFolderPath = set:WebFolder
        put(s_web._SitesQueue)
      of ?set:CertificatesFolder
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.CertificatesPath = set:CertificatesFolder
        put(s_web._SitesQueue)
        self.acme.SetFolders()
        s_web.Restart()
      of ?set:AcmeFolder
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.AcmeFolderPath = set:AcmeFolder
        put(s_web._SitesQueue)
        self.acme.SetFolders()
      of ?set:SessionTimeout
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.SessionExpiryAfterHS = set:SessionTimeout
        put(s_web._SitesQueue)
      of ?set:Staging
        self.acme.staging = set:staging
        if self.acme.staging = false
          self.acme.DeleteCertificates(set:Domains)
        end
      of ?set:Domains
        self.SetDomains(set:Domains,set:Passwords)
      Of ?RestartButton
        s_web.Restart()
      Of ?GetCertificatesButton
        If self.acme.SetAccountName(set:AccountName) = net:ok
          If self.acme.SetDomains(set:Domains,set:Passwords) = net:ok
            self.acme.CheckCertificates() ! may call restart server
          End
        End
      Of ?set:BindToIpAddress
        s_web._ServerIP = set:BindToIpAddress
        s_web.Restart()
      Of ?set:xFrameOptions
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.xFrameOptions = set:xFrameOptions
        put(s_web._SitesQueue)
      Of ?set:AccessControlAllowOrigin
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.AccessControlAllowOrigin = set:AccessControlAllowOrigin
        put(s_web._SitesQueue)
      Of ?set:StrictTransportSecurity
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.StrictTransportSecurity = set:StrictTransportSecurity
        put(s_web._SitesQueue)
      Of ?set:ContentSecurityPolicy
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.ContentSecurityPolicy = set:ContentSecurityPolicy
        put(s_web._SitesQueue)
      Of ?set:ContentSecurityPolicyReportOnly
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.ContentSecurityPolicyReportOnly = set:ContentSecurityPolicyReportOnly
        put(s_web._SitesQueue)
      Of ?set:ReferrerPolicy
        get(s_web._SitesQueue,1)
        s_web._SitesQueue.defaults.ReferrerPolicy = set:ReferrerPolicy
        put(s_web._SitesQueue)
      End
    End
    If set:LastCertificateCheckDate < today()
      Post(Event:Accepted,?GetCertificatesButton)
      set:LastCertificateCheckDate = today()
      do SaveSettings
    End
  PARENT.TakeEvent
    If Field() = ?LogQueue and Event() = Event:NewSelection
      Get(LogQueue,Choice(?LogQueue))
      If ErrorCode() = 0
        Case Upper(Sub(LogQueue.Desc,1,3))
        Of 'POS'
          web:LastPost = LogQueue.Desc
        Of 'GET'
          web:LastGet = LogQueue.Desc
        Else
          web:LastGet = LogQueue.Desc
        End
        Display()
      End
    End

