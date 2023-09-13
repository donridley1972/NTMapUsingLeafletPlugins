  Section('ProcessTag')
  loc:tag = Choose(Instring('?',loc:tag) > 0,sub(loc:tag,1,Instring('?',loc:tag)-1),loc:tag)
  Case loc:tag
    of 'pageheadertag'
      pageheadertag(Self)
    of 'updatedistrict'
      updatedistrict(Self)
    of 'generalmap'
      generalmap(Self)
    of 'loginform'
      loginform(Self)
    of 'accidentsmap'
      accidentsmap(Self)
    of 'browsedistrict'
      browsedistrict(Self)
    of 'browsepatrolarea'
      browsepatrolarea(Self)
    of 'patrolmap'
      patrolmap(Self)
    of 'updateaccident'
      updateaccident(Self)
    of 'browsepatrolareaboundary'
      browsepatrolareaboundary(Self)
    of 'pagefootertag'
      pagefootertag(Self)
    of 'updatepatrolarea'
      updatepatrolarea(Self)
    of 'browseaccident'
      browseaccident(Self)
    of 'updatepatrolareaboundary'
      updatepatrolareaboundary(Self)
  End
  Section('CallFormA')
    If Band(p_Stage, NET:WEB:StagePost + NET:WEB:StageValidate + NET:WEB:Cancel)
      case lower(self.formsettings.proc)
      Of 'updatedistrict'
         ReturnValue = UpdateDistrict(Self,p_stage)
         RETURN ReturnValue
      Of 'generalmap'
         ReturnValue = GeneralMap(Self,p_stage)
         RETURN ReturnValue
      Of 'loginform'
         ReturnValue = LoginForm(Self,p_stage)
         RETURN ReturnValue
      Of 'accidentsmap'
         ReturnValue = AccidentsMap(Self,p_stage)
         RETURN ReturnValue
      Of 'patrolmap'
         ReturnValue = PatrolMap(Self,p_stage)
         RETURN ReturnValue
      Of 'updateaccident'
         ReturnValue = UpdateAccident(Self,p_stage)
         RETURN ReturnValue
      Of 'updatepatrolarea'
         ReturnValue = UpdatePatrolArea(Self,p_stage)
         RETURN ReturnValue
      Of 'updatepatrolareaboundary'
         ReturnValue = UpdatePatrolAreaBoundary(Self,p_stage)
         RETURN ReturnValue
      End
    Else
      case lower(SELF.PageName)
        Of 'updatedistrict'
          ReturnValue = UpdateDistrict(Self,p_stage)
          RETURN ReturnValue
        Of 'generalmap'
          ReturnValue = GeneralMap(Self,p_stage)
          RETURN ReturnValue
        Of 'loginform'
          ReturnValue = LoginForm(Self,p_stage)
          RETURN ReturnValue
        Of 'accidentsmap'
          ReturnValue = AccidentsMap(Self,p_stage)
          RETURN ReturnValue
        Of 'patrolmap'
          ReturnValue = PatrolMap(Self,p_stage)
          RETURN ReturnValue
        Of 'updateaccident'
          ReturnValue = UpdateAccident(Self,p_stage)
          RETURN ReturnValue
        Of 'updatepatrolarea'
          ReturnValue = UpdatePatrolArea(Self,p_stage)
          RETURN ReturnValue
        Of 'updatepatrolareaboundary'
          ReturnValue = UpdatePatrolAreaBoundary(Self,p_stage)
          RETURN ReturnValue
      End
    End
  Section('CallFormB')
    If p_File &= district
       ReturnValue = UpdateDistrict(Self,p_stage)
       RETURN ReturnValue
    End
    If p_File &= accident
       ReturnValue = UpdateAccident(Self,p_stage)
       RETURN ReturnValue
    End
    If p_File &= patrolarea
       ReturnValue = UpdatePatrolArea(Self,p_stage)
       RETURN ReturnValue
    End
    If p_File &= patrolareaboundary
       ReturnValue = UpdatePatrolAreaBoundary(Self,p_stage)
       RETURN ReturnValue
    End
  Section('CallFormC')
    Case Lower(Self.FormSettings.ParentPage)
      Of 'generalmap'
        ReturnValue = GeneralMap(Self,p_Stage)
        Return ReturnValue
      Of 'loginform'
        ReturnValue = LoginForm(Self,p_Stage)
        Return ReturnValue
      Of 'accidentsmap'
        ReturnValue = AccidentsMap(Self,p_Stage)
        Return ReturnValue
      Of 'patrolmap'
        ReturnValue = PatrolMap(Self,p_Stage)
        Return ReturnValue
    End
  Section('ProcessYear')
