using com.matmir as matmir from '../db/schema';
using com.training as training from '../db/training';

// service CatalogService {

//     entity Products       as projection on matmir.materials.Products;
//     entity Suppliers      as projection on matmir.sales.Suppliers;
//     entity UnitOfMeasures as projection on matmir.materials.UnitOfMeasures;
//     entity Currency       as projection on matmir.materials.Currencies;
//     entity DimensionUnit  as projection on matmir.materials.DimensionUnits;
//     entity Category       as projection on matmir.materials.Categories;
//     entity SalesData      as projection on matmir.sales.SalesData;
//     entity Reviews        as projection on matmir.materials.ProductReview;
//     entity Months         as projection on matmir.sales.Months;
//     entity Orders         as projection on matmir.sales.Orders;
//     entity OrderItems     as projection on matmir.sales.OrderItems;

// }

define service CatalogService {

    entity Products          as
        select from matmir.reports.Products {
            ID,
            Name          as ProductName     @mandatory,
            Description                      @mandatory,
            ImageUrl,
            ReleaseDate,
            DiscontinuedDate,
            Price                            @mandatory,
            Height,
            Width,
            Depth,
            Quantity                         @(
                mandatory,
                assert.range : [
                    0.00,
                    20.00
                ]
            ),
            UnitOfMeasure as ToUnitOfMeasure @mandatory,
            Currency      as ToCurrency      @mandatory,
            Category      as ToCategory      @mandatory,
            Category.Name as Category        @readonly,
            DimensionUnit as ToDimensionUnit,
            SalesData,
            Supplier,
            Reviews,
            Rating,
            StockAvailability
        };

    entity Supplier          as
        select from matmir.sales.Suppliers {
            ID,
            Name,
            Email,
            Phone,
            Fax,
            Product as ToProduct
        };

    @readonly
    entity Reviews           as
        select from matmir.materials.ProductReview {
            ID,
            Name,
            Rating,
            Comment,
            createdAt,
            Product
        };

    @readonly
    entity SalesData         as
        select from matmir.sales.SalesData {
            ID,
            DeliveryDate,
            Revenue,
            Currency.ID               as CurrencyKey,
            DeliveryMonth.ID          as DeliveryMonthId,
            DeliveryMonth.Description as DeliveryMonth,
            Product                   as ToProduct
        };

    @readonly
    entity StockAvailability as
        select
            ID,
            Description,
            Product as ToProduct
        from matmir.materials.StockAvailability;

    // VH: Value Help

    @readonly
    entity VH_Categories     as
        select from matmir.materials.Categories {
            ID   as Code,
            Name as Text
        };

    @readonly
    entity VH_Currencies     as
        select from matmir.materials.Currencies {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_UnitOfMeasure  as
        select from matmir.materials.UnitOfMeasures {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_DimensionUnits as
        select from matmir.materials.DimensionUnits {
            ID          as Code,
            Description as Text
        }

};

define service MyService {

    entity SuppliersProduct as
        select from matmir.materials.Products[Name = 'Coffee']{
            *,
            Name,
            Description,
            Supplier.Address
        }
        where
            Supplier.Address.PostalCode = 98052;

    entity SuppliersToSales as
        select from matmir.materials.Products {
            Supplier.Email,
            Category.Name,
            SalesData.Currency.ID,
            SalesData.Currency.Description
        };

    entity EntityInfix      as
        select from matmir.materials.Products {
            Supplier[Name = 'Exotic Liquids'].Phone
        }
        where
            Name = 'Bread';

    entity EntityJoin       as
        select Phone from matmir.materials.Products as prod
        left join matmir.sales.Suppliers as supp
            on(
                    supp.ID   = prod.Supplier.ID
                and supp.Name = 'Exotic Liquids'
            )
        where
            prod.Name = 'Bread'


};

define service Reports {

    entity AverageRating as projection on matmir.reports.AverageRating;

    entity EntityCasting as projection on matmir.materials.EntityCasting;

    entity EntityExists as projection on matmir.materials.EntityExists;

};
