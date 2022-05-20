namespace com.matmir;

using {
    cuid,
    managed
} from '@sap/cds/common';

// type EmailsAddresses_01 : array of {
//     kind  : String;
//     email : String;

// };

// type EmailsAddresses_02 : many {
//     kind  : String;
//     email : String;

// };

// entity Emails {
//     email_01  : EmailsAddresses_01;
//     email_02  : EmailsAddresses_02;
//     email_03  : many {
//         kind  : String;
//         email : String;
//     }

// };

// type Gender : String enum {
//     male;
//     female;
// };

// entity Order {
//     clientGender : Gender;
//     status       : Integer enum {
//         submitted = 1;
//         fulfiller = 2;
//         shipped   = 3;
//         cancel    = -1;
//     };
//     priority     : String @assert.range enum {
//         high;
//         medium;
//         low;
//     }

// };

// entity Car {
//     key ID                 : UUID;
//         name               : String;
//         virtual discount_1 : Decimal;
//         virtual discount_2 : Decimal;

// };

type Name : String(50);

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

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
    Supplier         : Association to one Suppliers;
    UnitOfMeasure    : Association to one UnitOfMeasures;
    Currency         : Association to one Currencies;
    DimensionUnit    : Association to one DimensionUnits;
    Category         : Association to one Categories;
    SalesData        : Association to many SalesData
                           on SalesData.Product = $self;
    Reviews          : Association to many ProductReview
                           on Reviews.Product = $self;
};

extend Products with {
    PriceCondition     : String(2);
    PriceDetermination : String(3);

};

entity Suppliers : cuid, managed {
    Name    : Products:Name;
    Address : Address;
    Email   : String;
    Phone   : String;
    Fax     : String;
    Product : Association to many Products
                  on Product.Supplier = $self;

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

entity Months {
    key ID               : String(2);
        Description      : localized String;
        ShortDescription : localized String(3);

};

entity ProductReview : cuid, managed {
    Name    : String;
    Rating  : Integer;
    Comment : String;
    Product : Association to one Products;

};

entity SalesData : cuid, managed {
    DeliveryDate  : DateTime;
    Revenue       : Decimal(16, 2);
    Product       : Association to one Products;
    Currency      : Association to one Currencies;
    DeliveryMonth : Association to one Months;

};

entity SelProducts   as select from Products;

entity SelProducts1  as
    select from Products {
        *
    };

entity SelProducts2  as
    select from Products {
        Name,
        Price,
        Quantity
    };

entity SelProducts3  as
    select from Products as Ps
    left join ProductReview as PR
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

entity ProjProducts  as projection on Products;

entity ProjProducts2 as projection on Products {
    *
};

entity ProjProducts3 as projection on Products {
    ReleaseDate,
    Name
};

// entity ParamProducts(pName : String)      as
//     select from Products {
//         Name,
//         Price,
//         Quantity
//     }
//     where
//         Name = : pName;

// entity ProjParamProductos(pName : String) as projection on Products where Name = : pName;

// entity Course {
//     key ID      : UUID;
//         Student : Association to many StudentCourse
//                       on Student.Course = $self;

// };

// entity Student {
//     key ID     : UUID;
//         Course : Association to many StudentCourse
//                      on Course.Student = $self;

// };

// entity StudentCourse {
//     key ID      : UUID;
//         Course  : Association to one Course;
//         Student : Association to one Student;

// };

entity Orders : cuid {
    Date     : Date;
    Customer : String;
    Item     : Composition of many OrderItems
                   on Item.Order = $self;

};

entity OrderItems : cuid {
    Order    : Association to one Orders;
    Product  : Association to one Products;
    Quantity : Integer;

};
