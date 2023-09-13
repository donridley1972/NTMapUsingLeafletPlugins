  MEMBER('web76.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
web76_BC0:DctInit    PROCEDURE
web76_BC0:DctKill    PROCEDURE
web76_BC0:FilesInit  PROCEDURE
  END

Hide:Access:Accident CLASS(FileManager),TYPE               ! FileManager for Accident
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Accident CLASS(RelationManager),TYPE           ! RelationManager for Accident
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:District CLASS(FileManager),TYPE               ! FileManager for District
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:District CLASS(RelationManager),TYPE           ! RelationManager for District
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:PatrolArea CLASS(FileManager),TYPE             ! FileManager for PatrolArea
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:PatrolArea CLASS(RelationManager),TYPE         ! RelationManager for PatrolArea
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:PatrolAreaBoundary CLASS(FileManager),TYPE     ! FileManager for PatrolAreaBoundary
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:PatrolAreaBoundary CLASS(RelationManager),TYPE ! RelationManager for PatrolAreaBoundary
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:Accident &Hide:Access:Accident,AUTO,THREAD
_Hide:Relate:Accident &Hide:Relate:Accident,AUTO,THREAD
_Hide:Access:District &Hide:Access:District,AUTO,THREAD
_Hide:Relate:District &Hide:Relate:District,AUTO,THREAD
_Hide:Access:PatrolArea &Hide:Access:PatrolArea,AUTO,THREAD
_Hide:Relate:PatrolArea &Hide:Relate:PatrolArea,AUTO,THREAD
_Hide:Access:PatrolAreaBoundary &Hide:Access:PatrolAreaBoundary,AUTO,THREAD
_Hide:Relate:PatrolAreaBoundary &Hide:Relate:PatrolAreaBoundary,AUTO,THREAD


web76_BC0:DctInit PROCEDURE
  CODE
  _Hide:Access:Accident &= NEW(Hide:Access:Accident)
  _Hide:Relate:Accident &= NEW(Hide:Relate:Accident)
  _Hide:Access:District &= NEW(Hide:Access:District)
  _Hide:Relate:District &= NEW(Hide:Relate:District)
  _Hide:Access:PatrolArea &= NEW(Hide:Access:PatrolArea)
  _Hide:Relate:PatrolArea &= NEW(Hide:Relate:PatrolArea)
  _Hide:Access:PatrolAreaBoundary &= NEW(Hide:Access:PatrolAreaBoundary)
  _Hide:Relate:PatrolAreaBoundary &= NEW(Hide:Relate:PatrolAreaBoundary)
  Relate:Accident &= _Hide:Relate:Accident
  Relate:District &= _Hide:Relate:District
  Relate:PatrolArea &= _Hide:Relate:PatrolArea
  Relate:PatrolAreaBoundary &= _Hide:Relate:PatrolAreaBoundary


web76_BC0:FilesInit PROCEDURE
  CODE
  _Hide:Relate:Accident.Init
  _Hide:Relate:District.Init
  _Hide:Relate:PatrolArea.Init
  _Hide:Relate:PatrolAreaBoundary.Init


web76_BC0:DctKill PROCEDURE
  CODE
  _Hide:Relate:Accident.Kill
  DISPOSE(_Hide:Relate:Accident)
  _Hide:Relate:District.Kill
  DISPOSE(_Hide:Relate:District)
  _Hide:Relate:PatrolArea.Kill
  DISPOSE(_Hide:Relate:PatrolArea)
  _Hide:Relate:PatrolAreaBoundary.Kill
  DISPOSE(_Hide:Relate:PatrolAreaBoundary)


Hide:Relate:Accident.Init PROCEDURE
  CODE
  _Hide:Access:Accident.Init
  SELF.Init(Access:Accident,1)


Hide:Access:Accident.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Acc:Record
  SELF.FileNameValue = 'Accident'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Accident
  PARENT.Init
  Access:Accident &= SELF


Hide:Access:Accident.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Accident &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Accident.PrimeFields PROCEDURE

  CODE
  Acc:Guid = glo:st.Random(16,st:Upper+st:Number)          ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:Accident.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Accident,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Acc:GuidKey,'Acc:GuidKey',0)
    SELF.AddKey(Acc:DescKey,'Acc:DescKey',0)
    SELF.AddKey(Acc:DateKey,'Acc:DateKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Accident.Kill PROCEDURE

  CODE
  _Hide:Access:Accident.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Accident &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Accident)                           ! destroy the file manager


Hide:Relate:District.Init PROCEDURE
  CODE
  _Hide:Access:District.Init
  SELF.Init(Access:District,1)


Hide:Access:District.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Dis:Record
  SELF.FileNameValue = 'District'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= District
  PARENT.Init
  Access:District &= SELF


Hide:Access:District.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:District &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:District.PrimeFields PROCEDURE

  CODE
  Dis:Guid = glo:st.Random(16,st:Upper+st:Number)          ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:District.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(District,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Dis:GuidKey,'Dis:GuidKey',0)
    SELF.AddKey(Dis:DescKey,'Dis:DescKey',0)
    SELF.AddKey(Dis:NameKey,'Dis:NameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:District.Kill PROCEDURE

  CODE
  _Hide:Access:District.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:District &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:District)                           ! destroy the file manager


Hide:Relate:PatrolArea.Init PROCEDURE
  CODE
  _Hide:Access:PatrolArea.Init
  SELF.Init(Access:PatrolArea,1)


Hide:Access:PatrolArea.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Pat:Record
  SELF.FileNameValue = 'PatrolArea'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= PatrolArea
  PARENT.Init
  Access:PatrolArea &= SELF


Hide:Access:PatrolArea.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:PatrolArea &= NULL                                ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:PatrolArea.PrimeFields PROCEDURE

  CODE
  Pat:Guid = glo:st.Random(16,st:Upper+st:Number)          ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:PatrolArea.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(PatrolArea,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Pat:GuidKey,'Pat:GuidKey',0)
    SELF.AddKey(Pat:NameKey,'Pat:NameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:PatrolArea.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:PatrolAreaBoundary,RI:CASCADE,RI:CASCADE,Ptb:PatrolKey)
  SELF.AddRelationLink(Pat:Guid,Ptb:PatGuid)


Hide:Relate:PatrolArea.Kill PROCEDURE

  CODE
  _Hide:Access:PatrolArea.Kill                             ! Kill the file manager
  PARENT.Kill
  Relate:PatrolArea &= NULL                                ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:PatrolArea)                         ! destroy the file manager


Hide:Relate:PatrolAreaBoundary.Init PROCEDURE
  CODE
  _Hide:Access:PatrolAreaBoundary.Init
  SELF.Init(Access:PatrolAreaBoundary,1)


Hide:Access:PatrolAreaBoundary.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Ptb:Record
  SELF.FileNameValue = 'PatrolAreaBoundary'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= PatrolAreaBoundary
  PARENT.Init
  Access:PatrolAreaBoundary &= SELF


Hide:Access:PatrolAreaBoundary.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:PatrolAreaBoundary &= NULL                        ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:PatrolAreaBoundary.PrimeFields PROCEDURE

  CODE
  Ptb:Guid = glo:st.Random(16,st:Upper+st:Number)          ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:PatrolAreaBoundary.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(PatrolAreaBoundary,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Ptb:GuidKey,'Ptb:GuidKey',0)
    SELF.AddKey(Ptb:PatrolKey,'Ptb:PatrolKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:PatrolAreaBoundary.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:PatrolArea)


Hide:Relate:PatrolAreaBoundary.Kill PROCEDURE

  CODE
  _Hide:Access:PatrolAreaBoundary.Kill                     ! Kill the file manager
  PARENT.Kill
  Relate:PatrolAreaBoundary &= NULL                        ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:PatrolAreaBoundary)                 ! destroy the file manager

