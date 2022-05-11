using {com.matmir as matmir} from '../db/schema';

service CustomerService {

    entity CustomerSrv as projection on matmir.Customer;

}
