using {com.matmir as matmir} from '../db/schema';

service CatalogService {

    entity Products       as projection on matmir.Products;
    entity Suppliers      as projection on matmir.Suppliers;
    entity UnitOfMeasures as projection on matmir.UnitOfMeasures;
    entity Currency       as projection on matmir.Currencies;
    entity DimensionUnit  as projection on matmir.DimensionUnits;
    entity Category       as projection on matmir.Categories;
    entity SalesData      as projection on matmir.SalesData;
    entity Reviews        as projection on matmir.ProductReview;
    entity Months         as projection on matmir.Months;
    entity Orders         as projection on matmir.Orders;
    entity OrderItems     as projection on matmir.OrderItems;

}
