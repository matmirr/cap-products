using com.training as training from '../db/training';

define service ManageOrders {

    type cancelationResult {
        status  : String enum {
            Succeded;
            Failed
        };
        message : String;
    }

    // entity Orders as projection on training.Orders;
    // function getClientTaxRate(clientEmail : String(65)) returns Decimal(4, 2);
    // action   cancelOrder(clientEmail : String(65))      returns cancelationResult;

    entity Orders as projection on training.Orders actions {
        function getClientTaxRate(clientEmail : String(65)) returns Decimal(4, 2);
        action   cancelOrder(clientEmail : String(65))      returns cancelationResult;        
    }

}
