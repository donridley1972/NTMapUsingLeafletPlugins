  MEMBER('web76.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('web76_BC0.CLW')
web76_BC0:DctInit             PROCEDURE
web76_BC0:DctKill             PROCEDURE
web76_BC0:FilesInit           PROCEDURE
    END
  END

DctInit PROCEDURE
  CODE
  web76_BC0:DctInit
  web76_BC0:FilesInit


DctKill PROCEDURE
  CODE
  web76_BC0:DctKill

