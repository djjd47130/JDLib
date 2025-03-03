object dmJDGraphicsDWScript: TdmJDGraphicsDWScript
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 402
  Width = 542
  object DWS: TDelphiWebScript
    Left = 96
    Top = 64
  end
  object dwsRTTIConnector1: TdwsRTTIConnector
    Script = DWS
    StaticSymbols = False
    Left = 200
    Top = 64
  end
  object dwsUnit1: TdwsUnit
    UnitName = ''
    StaticSymbols = False
    Left = 200
    Top = 120
  end
end
