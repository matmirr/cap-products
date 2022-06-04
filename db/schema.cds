namespace com.matmir;

using {
    cuid,
    managed
} from '@sap/cds/common';

type Name : String(50);

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

context materials {

    entity Products : cuid, managed {
        createdAt        : Timestamp @cds.on.insert : $now;
        modifiedAt       : Timestamp @cds.on.insert : $now  @cds.on.update : $now;
        Name             : localized String not null;
        Description      : localized String;
        ImageUrl         : String;
        ReleaseDate      : DateTime default $now;
        DiscontinuedDate : DateTime;
        Price            : Decimal(16, 2);
        Height           : type of Price;
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        Supplier         : Association to one sales.Suppliers;
        UnitOfMeasure    : Association to one UnitOfMeasures;
        Currency         : Association to one Currencies;
        DimensionUnit    : Association to one DimensionUnits;
        Category         : Association to one Categories;
        SalesData        : Association to many sales.SalesData
                               on SalesData.Product = $self;
        Reviews          : Association to many ProductReview
                               on Reviews.Product = $self;
    };

    extend Products with {
        PriceCondition     : String(2);
        PriceDetermination : String(3);

    };


    entity Categories {
        key ID   : String(1);
            Name : localized String;

    };

    entity StockAvailability {
        key ID          : Integer;
            Description : localized String;
            Product     : Association to one Products;
    };

    entity Currencies {
        key ID          : String(3);
            Description : localized String;

    };

    entity UnitOfMeasures {
        key ID          : String(2);
            Description : localized String;

    };

    entity DimensionUnits {
        key ID          : String(2);
            Description : localized String;

    };

    entity ProductReview : cuid, managed {
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to one Products;

    };


    entity ProjProducts  as projection on Products;

    entity ProjProducts2 as projection on Products {
        *
    };

    entity ProjProducts3 as projection on Products {
        ReleaseDate,
        Name
    };

    entity EntityCasting as
        select from Products {
            cast(Price as Integer) as Price,
            Price                  as Price2 : Integer
        };

    entity EntityExists   as
        select from Products {
            Name
        }
        where exists Supplier[Name = 'Exotic Liquids'];

};

context sales {

    entity Orders : cuid {
        Date     : Date;
        Customer : String;
        Item     : Composition of many OrderItems
                       on Item.Order = $self;

    };

    entity OrderItems : cuid {
        Order    : Association to one Orders;
        Product  : Association to one materials.Products;
        Quantity : Integer;

    };

    entity Suppliers : cuid, managed {
        Name    : materials.Products:Name;
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many materials.Products
                      on Product.Supplier = $self;

    };

    entity Months {
        key ID               : String(2);
            Description      : localized String;
            ShortDescription : localized String(3);

    };

    entity SalesData : cuid, managed {
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to one materials.Products;
        Currency      : Association to one materials.Currencies;
        DeliveryMonth : Association to one Months;

    };

    entity SelProducts  as select from materials.Products;

    entity SelProducts1 as
        select from materials.Products {
            *
        };

    entity SelProducts2 as
        select from materials.Products {
            Name,
            Price,
            Quantity
        };

    entity SelProducts3 as
        select from materials.Products as Ps
        left join materials.ProductReview as PR
            on Ps.Name = PR.Name
        {
            Rating,
            Ps.Name,
            sum(Price) as totalPrice
        }
        group by
            Rating,
            Ps.Name
        order by
            Rating;

};

context reports {

    entity AverageRating as
        select from materials.ProductReview {
            Product.ID  as ProductID,
            avg(Rating) as AverageRating : Decimal(16, 2)
        }
        group by
            Product.ID;

    entity Products      as
        select from matmir.materials.Products
        mixin {
            ToStockAvailability : Association to one matmir.materials.StockAvailability
                                      on ToStockAvailability.ID = $projection.StockAvailability;
            ToAverageRating     : Association to one AverageRating
                                      on ToAverageRating.ProductID = ID
        }
        into {
            *,
            ToAverageRating.AverageRating as Rating,
            case
                when
                    Quantity >= 8
                then
                    3
                when
                    Quantity > 0
                then
                    2
                else
                    1
            end                           as StockAvailability : Integer

        };

}
