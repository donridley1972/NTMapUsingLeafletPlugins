  MEMBER('web76.clw')
    MAP
      INCLUDE('web76001.Inc'),ONCE ! In WebHandler so make all procedures in scope
! WebHandler : ActiveTemplate = IncludeNetTalkObject(NetTalk)
      INCLUDE('web76003.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76004.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76005.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76006.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76007.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76008.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76009.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76010.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76011.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76012.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76013.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76014.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76015.Inc'),ONCE ! In WebHandler so make all procedures in scope
      INCLUDE('web76016.Inc'),ONCE ! In WebHandler so make all procedures in scope
! WebServer : ActiveTemplate = CloseButton(ABC)
! WebServer : ActiveTemplate = IncludeNetTalkObject(NetTalk)
! WebServer : ActiveTemplate = NetWebServerLogging(NetTalk)
! WebServer : ActiveTemplate = NetWebServerPerformance(NetTalk)
! WebServer : ActiveTemplate = NetWebServerSettings(NetTalk)
    END
        ! District / district - FileType FILE
        ! PatrolArea / patrolarea - FileType FILE
        ! PatrolAreaBoundary / patrolareaboundary - FileType FILE
  ! ----------------------------------------------------------------------------------------
! ----------------------------------------------------------------------------------------
! These procedures support the NetTalk Web Server templates. They are sufficiently generic
! that there is no need to put them in the application true, however are dependant on the
! dictionary and/or application such that they need to be generated, and cannot be inserted
! as methods in the class.
! ----------------------------------------------------------------------------------------
NetWebRelationManager PROCEDURE  (FILE p_file)
RM       &RelationManager
  CODE
  RM &= NULL
  If p_FILE &= NULL then Return RM.
  If p_File &= Relate:accident.Me.File then RM &= Relate:accident.
  If p_File &= Relate:district.Me.File then RM &= Relate:district.
  If p_File &= Relate:patrolarea.Me.File then RM &= Relate:patrolarea.
  If p_File &= Relate:patrolareaboundary.Me.File then RM &= Relate:patrolareaboundary.
  Return RM
! ----------------------------------------------------------------------------------------
NetWebFileNamed PROCEDURE  (string p_file)
F        &File
  CODE
  F &= NULL
  Case Lower(p_file)
  Of 'accident'
    F &= accident
  Of 'district'
    F &= district
  Of 'patrolarea'
    F &= patrolarea
  Of 'patrolareaboundary'
    F &= patrolareaboundary
  End
  Return F
! ----------------------------------------------------------------------------------------
! ----------------------------------------------------------------------------------------
! ----------------------------------------------------------------------------------------
NetWebDLL_web76_SendFile PROCEDURE  (NetWebServerWorker p_web, string p_Filename, String p_Parent)
loc:parent      string(252)   ! should always be a lower-case string
loc:done        Long
loc:filename    string(252)
  CODE
  loc:parent = p_parent
  loc:filename = p_filename
  do CaseStart:web76
  Return Loc:Done

! ----------------------------------------------------------------
SendFile:web76:R1  Routine
  Case lower(loc:filename)
  of 'pageheadertag'
  orof 'pageheadertag' & '_' & loc:parent
  orof 'pageheadertag' & net:PARENTSEPARATOR & loc:parent
      p_web.Ajax = 1
      PageHeaderTag(p_web)
      p_web.Sendfooter(12)
      loc:Done = 1
  of 'indexpage'
  orof 'index.htm'
    IndexPage(p_web)
    loc:Done = 1 ; Exit
  of 'browsedistrict'
  orof 'browsedistrict' & '_' & loc:parent
  orof 'browsedistrict' & net:PARENTSEPARATOR & loc:parent
    p_web.MakePage('BrowseDistrict',Net:Web:Browse,0,'District',,,) !sf1
    loc:Done = 1
  of 'browsepatrolarea'
  orof 'browsepatrolarea' & '_' & loc:parent
  orof 'browsepatrolarea' & net:PARENTSEPARATOR & loc:parent
    p_web.MakePage('BrowsePatrolArea',Net:Web:Browse,0,'Patrol Area',,,) !sf1
    loc:Done = 1
  of 'browsepatrolareaboundary'
  orof 'browsepatrolareaboundary' & '_' & loc:parent
  orof 'browsepatrolareaboundary' & net:PARENTSEPARATOR & loc:parent
    p_web.MakePage('BrowsePatrolAreaBoundary',Net:Web:Browse,0,'Patrol Area Boundary',,,) !sf1
    loc:Done = 1
  of 'pagefootertag'
  orof 'pagefootertag' & '_' & loc:parent
  orof 'pagefootertag' & net:PARENTSEPARATOR & loc:parent
      p_web.Ajax = 1
      PageFooterTag(p_web)
      p_web.Sendfooter(12)
      loc:Done = 1
  of 'browseaccident'
  orof 'browseaccident' & '_' & loc:parent
  orof 'browseaccident' & net:PARENTSEPARATOR & loc:parent
    p_web.MakePage('BrowseAccident',Net:Web:Browse,0,'Accident',,,) !sf1
    loc:Done = 1
  End ! Case Loc:filename
! ----------------------------------------------------------------------
ServicesAndMethods:web76  routine
!------------------------------------------------------------------------
Case:UpdateDistrict  Routine
  Case lower(loc:filename)
  of 'updatedistrict'
    p_web.MakePage('UpdateDistrict',Net:Web:Form,0,'Update District',,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatedistrict_tabchanged')
    UpdateDistrict(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatedistrict_nexttab_0')
    UpdateDistrict(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatedistrict_tab_0')
  orof p_web.nocolon('updatedistrict_dis:name_value')
  orof p_web.nocolon('updatedistrict_dis:name_value')
  orof p_web.nocolon('updatedistrict_dis:description_value')
  orof p_web.nocolon('updatedistrict_dis:description_value')
  orof p_web.nocolon('updatedistrict_dis:border_value')
  orof p_web.nocolon('updatedistrict_dis:border_value')
    UpdateDistrict(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  of p_web.nocolon('updatedistrict_nexttab_1')
    UpdateDistrict(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatedistrict_tab_1')
    UpdateDistrict(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
Case:GeneralMap  Routine
  Case lower(loc:filename)
  of 'generalmap'
    p_web.MakePage('GeneralMap',Net:Web:Form,0,,,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('generalmap_tabchanged')
    GeneralMap(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('generalmap_nexttab_0')
    GeneralMap(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('generalmap_tab_0')
  orof p_web.nocolon('generalmap_home_value')
  orof p_web.nocolon('generalmap_gm:latitude_value')
  orof p_web.nocolon('generalmap_gm:latitude_value')
  orof p_web.nocolon('generalmap_gm:longitude_value')
  orof p_web.nocolon('generalmap_gm:longitude_value')
  orof p_web.nocolon('generalmap_gm:zoom_value')
  orof p_web.nocolon('generalmap_gm:zoom_value')
  orof p_web.nocolon('generalmap_gotobutton_value')
  orof p_web.nocolon('generalmap_generalmap_value')
    GeneralMap(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
Case:LoginForm  Routine
  Case lower(loc:filename)
  of 'loginform'
    p_web.MakePage('LoginForm',Net:Web:Form,0,,,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('loginform_tabchanged')
    LoginForm(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('loginform_nexttab_0')
    LoginForm(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('loginform_tab_0')
  orof p_web.nocolon('loginform_loc:login_value')
  orof p_web.nocolon('loginform_loc:login_value')
  orof p_web.nocolon('loginform_loc:password_value')
  orof p_web.nocolon('loginform_loc:password_value')
  orof p_web.nocolon('loginform_loc:remember_value')
  orof p_web.nocolon('loginform_loc:remember_value')
  orof p_web.nocolon('loginform_loc:hash_value')
  orof p_web.nocolon('loginform_loc:hash_value')
    LoginForm(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
Case:AccidentsMap  Routine
  Case lower(loc:filename)
  of 'accidentsmap'
    p_web.MakePage('AccidentsMap',Net:Web:Form,0,,,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('accidentsmap_tabchanged')
    AccidentsMap(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('accidentsmap_nexttab_0')
    AccidentsMap(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('accidentsmap_tab_0')
  orof p_web.nocolon('accidentsmap_accidentsmap_value')
    AccidentsMap(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
Case:PatrolMap  Routine
  Case lower(loc:filename)
  of 'patrolmap'
    p_web.MakePage('PatrolMap',Net:Web:Form,0,,,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('patrolmap_tabchanged')
    PatrolMap(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('patrolmap_nexttab_0')
    PatrolMap(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('patrolmap_tab_0')
  orof p_web.nocolon('patrolmap_loc:patrol_value')
  orof p_web.nocolon('patrolmap_loc:patrol_value')
  orof p_web.nocolon('patrolmap_patrolmap_value')
    PatrolMap(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
Case:UpdateAccident  Routine
  Case lower(loc:filename)
  of 'updateaccident'
    p_web.MakePage('UpdateAccident',Net:Web:Form,0,'Update Accident',,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updateaccident_tabchanged')
    UpdateAccident(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updateaccident_nexttab_0')
    UpdateAccident(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updateaccident_tab_0')
  orof p_web.nocolon('updateaccident_acc:description_value')
  orof p_web.nocolon('updateaccident_acc:description_value')
  orof p_web.nocolon('updateaccident_acc:latitude_value')
  orof p_web.nocolon('updateaccident_acc:latitude_value')
  orof p_web.nocolon('updateaccident_acc:longitude_value')
  orof p_web.nocolon('updateaccident_acc:longitude_value')
  orof p_web.nocolon('updateaccident_acc:date_value')
  orof p_web.nocolon('updateaccident_acc:date_value')
  orof p_web.nocolon('updateaccident_acc:time_value')
  orof p_web.nocolon('updateaccident_acc:time_value')
  orof p_web.nocolon('updateaccident_acc:type_value')
  orof p_web.nocolon('updateaccident_acc:type_value')
  orof p_web.nocolon('updateaccident_acc:markerobject_value')
  orof p_web.nocolon('updateaccident_acc:markerobject_value')
  orof p_web.nocolon('updateaccident_acc:markeropacity_value')
  orof p_web.nocolon('updateaccident_acc:markeropacity_value')
    UpdateAccident(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
Case:UpdatePatrolArea  Routine
  Case lower(loc:filename)
  of 'updatepatrolarea'
    p_web.MakePage('UpdatePatrolArea',Net:Web:Form,0,'Update Patrol Area',,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatepatrolarea_tabchanged')
    UpdatePatrolArea(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatepatrolarea_nexttab_0')
    UpdatePatrolArea(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatepatrolarea_tab_0')
  orof p_web.nocolon('updatepatrolarea_pat:name_value')
  orof p_web.nocolon('updatepatrolarea_pat:name_value')
  orof p_web.nocolon('updatepatrolarea_pat:latitude_value')
  orof p_web.nocolon('updatepatrolarea_pat:latitude_value')
  orof p_web.nocolon('updatepatrolarea_pat:longitude_value')
  orof p_web.nocolon('updatepatrolarea_pat:longitude_value')
  orof p_web.nocolon('updatepatrolarea_pat:zoom_value')
  orof p_web.nocolon('updatepatrolarea_pat:zoom_value')
  orof p_web.nocolon('updatepatrolarea_patrolareamap_value')
    UpdatePatrolArea(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  of p_web.nocolon('updatepatrolarea_nexttab_1')
    UpdatePatrolArea(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatepatrolarea_tab_1')
  orof p_web.nocolon('updatepatrolarea_browsepatrolareaboundary_value')
  orof p_web.nocolon('updatepatrolarea' & net:parentseparator & 'browsepatrolareaboundary_value')
    UpdatePatrolArea(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
Case:UpdatePatrolAreaBoundary  Routine
  Case lower(loc:filename)
  of 'updatepatrolareaboundary'
    p_web.MakePage('UpdatePatrolAreaBoundary',Net:Web:Form,0,'Update Patrol Area Boundary',,,)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatepatrolareaboundary_tabchanged')
    UpdatePatrolAreaBoundary(p_web,Net:Web:Div)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatepatrolareaboundary_nexttab_0')
    UpdatePatrolAreaBoundary(p_web,Net:Web:NextTab)
    p_web.Sendfooter(5)
    loc:Done = 1 ; Exit
  of p_web.nocolon('updatepatrolareaboundary_tab_0')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:patguid_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:patguid_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:order_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:order_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:description_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:description_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:latitude_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:latitude_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:longitude_value')
  orof p_web.nocolon('updatepatrolareaboundary_ptb:longitude_value')
  orof p_web.nocolon('updatepatrolareaboundary_pointmap_value')
    UpdatePatrolAreaBoundary(p_web,Net:Web:Div)
    p_web.Sendfooter(11)
    loc:Done = 1 ; exit
  End ! Case

!------------------------------------------------------------------------
CaseStart:web76  routine
  do ServicesAndMethods:web76
  if loc:done then exit.
  do SendFile:web76:R1
  if loc:done then exit.
  do Case:UpdateDistrict
  if loc:done then exit.
  do Case:GeneralMap
  if loc:done then exit.
  do Case:LoginForm
  if loc:done then exit.
  do Case:AccidentsMap
  if loc:done then exit.
  do Case:PatrolMap
  if loc:done then exit.
  do Case:UpdateAccident
  if loc:done then exit.
  do Case:UpdatePatrolArea
  if loc:done then exit.
  do Case:UpdatePatrolAreaBoundary
  if loc:done then exit.

