   PROGRAM


NetTalk:TemplateVersion equate('12.63')
ActivateNetTalk   EQUATE(1)
  include('NetAll.inc'),once
  include('NetMap.inc'),once
  include('NetTalk.inc'),once
  include('NetSimp.inc'),once
  include('NetFtp.inc'),once
  include('NetHttp.inc'),once
  include('NetWww.inc'),once
  include('NetSync.inc'),once
  include('NetWeb.inc'),once
  include('NetWebSessions.inc'),once
  include('NetWebSocketClient.inc'),once
  include('NetWebSocketServer.inc'),once
  include('NetWebM.inc'),once
  include('NetWSDL.inc'),once
  include('NetEmail.inc'),once
  include('NetFile.inc'),once
  include('NetWebSms.inc'),once
  Include('NetOauth.inc'),once
  Include('NetLDAP.inc'),once
  Include('NetMaps.inc'),once
  Include('NetDrive.inc'),once
  Include('NetSms.inc'),once
StringTheory:TemplateVersion equate('3.62')
xFiles:TemplateVersion equate('4.24')
jFiles:TemplateVersion equate('3.03')
Reflection:TemplateVersion equate('1.24')

   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
  include('cwsynchc.inc'),once  ! added by NetTalk
  include('StringTheory.Inc'),ONCE
   include('xfiles.inc'),ONCE
   include('jFiles.inc'),ONCE
  include('Reflection.Inc'),ONCE

   MAP
     MODULE('WEB76_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('WEB76004.CLW')
UpdatePatrolArea       FUNCTION(NetWebServerWorker p_web,long p_action=0),long,proc   !
     END
     MODULE('WEB76005.CLW')
BrowsePatrolAreaBoundary PROCEDURE(NetWebServerWorker p_web)   !
     END
     MODULE('WEB76006.CLW')
UpdatePatrolAreaBoundary FUNCTION(NetWebServerWorker p_web,long p_action=0),long,proc   !
     END
     MODULE('WEB76007.CLW')
BrowsePatrolArea       PROCEDURE(NetWebServerWorker p_web)   !
     END
     MODULE('WEB76009.CLW')
PageHeaderTag          PROCEDURE(NetWebServerWorker p_web)   !***** Includes Menu *****
     END
     MODULE('WEB76011.CLW')
UpdateAccident         FUNCTION(NetWebServerWorker p_web,long p_action=0),long,proc   !
     END
     MODULE('WEB76013.CLW')
UpdateDistrict         FUNCTION(NetWebServerWorker p_web,long p_action=0),long,proc   !
     END
     MODULE('WEB76014.CLW')
BrowseDistrict         PROCEDURE(NetWebServerWorker p_web)   !
     END
     MODULE('WEB76015.CLW')
BrowseAccident         PROCEDURE(NetWebServerWorker p_web)   !
     END
     MODULE('WEB76016.CLW')
PageFooterTag          PROCEDURE(NetWebServerWorker p_web)   !
     END
     MODULE('WEB76017.CLW')
WebServer              PROCEDURE(<NetWebServer pServer>),name('WebServer')   !
     END
       Module('web76_nw.clw')
          NetWebRelationManager (FILE p_file),*RelationManager
          NetWebFileNamed (string p_file),*File
          NetWebDLL_web76_SendFile (NetWebServerWorker p_web, string p_Filename, String p_Parent),Long,Proc
       End
   END

  include('StringTheory.Inc'),ONCE
Glo:st               CLASS(StringTheory)
                     END
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
Accident             FILE,DRIVER('TOPSPEED'),NAME('Accident'),PRE(Acc),CREATE,BINDABLE,THREAD !                    
GuidKey                  KEY(Acc:Guid),NOCASE,PRIMARY      !                    
DescKey                  KEY(Acc:Description),DUP,NOCASE   !                    
DateKey                  KEY(Acc:Date,Acc:Time),DUP,NOCASE !                    
Record                   RECORD,PRE()
Guid                        STRING(16)                     !                    
Date                        LONG                           !                    
Time                        LONG                           !                    
Type                        LONG                           !                    
Description                 STRING(255)                    !                    
Latitude                    REAL                           !                    
Longitude                   REAL                           !                    
markerObject                STRING(30)                     !                    
markerOpacity               LONG                           !in %                
                         END
                     END                       

District             FILE,DRIVER('TOPSPEED'),NAME('District'),PRE(Dis),CREATE,BINDABLE,THREAD !                    
GuidKey                  KEY(Dis:Guid),NOCASE,PRIMARY      !                    
DescKey                  KEY(Dis:Description),DUP,NOCASE   !                    
NameKey                  KEY(Dis:Name),NOCASE              !                    
Record                   RECORD,PRE()
Guid                        STRING(16)                     !                    
Name                        STRING(20)                     !                    
Description                 STRING(255)                    !                    
Border                      STRING(1024)                   !                    
                         END
                     END                       

PatrolArea           FILE,DRIVER('TOPSPEED'),NAME('PatrolArea'),PRE(Pat),CREATE,BINDABLE,THREAD !                    
GuidKey                  KEY(Pat:Guid),NOCASE,PRIMARY      !                    
NameKey                  KEY(Pat:Name),NOCASE              !                    
Record                   RECORD,PRE()
Guid                        STRING(16)                     !                    
Name                        STRING(20)                     !                    
Latitude                    STRING(20)                     !                    
Longitude                   STRING(20)                     !                    
Zoom                        LONG                           !                    
                         END
                     END                       

PatrolAreaBoundary   FILE,DRIVER('TOPSPEED'),NAME('PatrolAreaBoundary'),PRE(Ptb),CREATE,BINDABLE,THREAD !                    
GuidKey                  KEY(Ptb:Guid),NOCASE,PRIMARY      !                    
PatrolKey                KEY(Ptb:PatGuid,Ptb:Order),DUP,NOCASE !                    
Record                   RECORD,PRE()
Guid                        STRING(16)                     !                    
PatGuid                     STRING(16)                     !                    
Order                       LONG                           !                    
Description                 STRING(100)                    !                    
Latitude                    STRING(20)                     !                    
Longitude                   STRING(20)                     !                    
                         END
                     END                       

!endregion

  include('StringTheory.Inc'),ONCE
Access:Accident      &FileManager,THREAD                   ! FileManager for Accident
Relate:Accident      &RelationManager,THREAD               ! RelationManager for Accident
Access:District      &FileManager,THREAD                   ! FileManager for District
Relate:District      &RelationManager,THREAD               ! RelationManager for District
Access:PatrolArea    &FileManager,THREAD                   ! FileManager for PatrolArea
Relate:PatrolArea    &RelationManager,THREAD               ! RelationManager for PatrolArea
Access:PatrolAreaBoundary &FileManager,THREAD              ! FileManager for PatrolAreaBoundary
Relate:PatrolAreaBoundary &RelationManager,THREAD          ! RelationManager for PatrolAreaBoundary

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
  GlobalErrors.Init(GlobalErrorStatus)
  FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
  FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
  FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
  INIMgr.Init('.\web76.INI', NVD_INI)                      ! Configure INIManager to use INI file
  DctInit
                             ! Begin Generated by NetTalk Extension Template
  
    if ~command ('/netnolog') and (command ('/nettalklog') or command ('/nettalklogerrors') or command ('/neterrors') or command ('/netall'))
      NetDebugTrace ('[Nettalk Template] NetTalk Template version 12.63')
      NetDebugTrace ('[Nettalk Template] NetTalk Template using Clarion ' & 8000)
      NetDebugTrace ('[Nettalk Template] NetTalk Object version ' & NETTALK:VERSION )
      NetDebugTrace ('[Nettalk Template] ABC Template Chain')
    end
                             ! End Generated by Extension Template
  WebServer
  INIMgr.Update
                             ! Begin Generated by NetTalk Extension Template
    NetCloseCallBackWindow() ! Tell NetTalk DLL to shutdown it's WinSock Call Back Window
  
    if ~command ('/netnolog') and (command ('/nettalklog') or command ('/nettalklogerrors') or command ('/neterrors') or command ('/netall'))
      NetDebugTrace ('[Nettalk Template] NetTalk Template version 12.63')
      NetDebugTrace ('[Nettalk Template] NetTalk Template using Clarion ' & 8000)
      NetDebugTrace ('[Nettalk Template] Closing Down NetTalk (Object) version ' & NETTALK:VERSION)
    end
                             ! End Generated by Extension Template
  INIMgr.Kill                                              ! Destroy INI manager
  FuzzyMatcher.Kill                                        ! Destroy fuzzy matcher


Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

