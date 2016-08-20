inherited frmCustomerList: TfrmCustomerList
  Caption = 'Customer List'
  ExplicitWidth = 634
  ExplicitHeight = 627
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    inherited Label1: TLabel
      Width = 87
      Caption = 'Search Customers'
      ExplicitWidth = 87
    end
  end
  inherited pResults: TPanel
    inherited Results: TImageGrid
      OnDblClick = ResultsDblClick
    end
  end
end
