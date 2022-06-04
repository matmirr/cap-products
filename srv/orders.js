const cds = require("@sap/cds");

const { Orders } = cds.entities("com.training");

const createOrder = (order) => {

    return INSERT.into(Orders).entries({
        ClientEmail: order.ClientEmail,
        FirstName: order.FirstName,
        LastName: order.LastName,
        CreatedOn: order.CreatedOn,
    })

};

const processCreation = (req, resolve, reject) => {

    console.log("resolve:", resolve);
    console.log("reject:", reject);

    if (typeof resolve !== "undefined") {

        return req.data;

    } else {

        req.error(409, "Record Not Inserted");

    }

};

const readAll = () => SELECT.from(Orders);

const readByEmail = (email) => SELECT.from`com.training.Orders`
    .where`ClientEmail = ${email}`;

const reviewOrders = (orders) => orders.map(order => order.Reviewed = true);

const updateOrder = (order) => {

    return [
        UPDATE(Orders, order.ClientEmail).set({
            FirstName: order.FirstName,
            LastName: order.LastName,
        }),
    ]
};

const processModification = (req, resolve, reject) => {

    console.log("resolve:", resolve);
    console.log("reject:", reject);

    // resolve[0] == 0 -> Record not found!
    if (resolve[0] == 0) {

        req.error(409, "Record Not Found");

    }
};

const deleteOrder = (order) => {

    return DELETE.from(Orders).where({
        ClientEmail: order.ClientEmail,
    })

};

const processDeletion = (req, resolve, reject) => {

    console.log("resolve:", resolve);
    console.log("reject:", reject);

    if (resolve !== 1) {
        req.error(409, "Record Not Found");
    }

};

module.exports = (srv) => {

    //***BEFORE->CREATE***//
    srv.before("CREATE", "Orders", (req) => {

        req.data.CreatedOn = new Date().toISOString().slice(0, 10);

        return req

    });

    //*******CREATE*******//
    srv.on("CREATE", "Orders", async (req) => {

        let result = await cds
            .transaction(req)
            .run(createOrder(req.data))
            .then((resolve, reject) => processCreation(req, resolve, reject))
            .catch((err) => {
                console.log(err);
                req.error(err.code, err.message);
            });

        console.log("Before End", result);

        return result;

    });

    //********READ********//
    srv.on("READ", "Orders", async (req) => {

        if (req.data.ClientEmail !== undefined) {

            return await readByEmail(req.data.ClientEmail);

        }

        return await readAll();

    });

    //*****AFTER->READ*****//
    srv.after("READ", "Orders", (data) => {

        return reviewOrders(data);

    });

    //*******UPDATE*******//
    srv.on("UPDATE", "Orders", async (req) => {

        let result = await cds
            .transaction(req)
            .run(updateOrder(req.data))
            .then((resolve, reject) => processModification(req, resolve, reject))
            .catch((err) => {
                console.log(err);
                req.error(err.code, err.message);
            });

        console.log("Before End", result);

        return result;

    });

    //*******DELETE*******//
    srv.on("DELETE", "Orders", async (req) => {

        let result = await cds
            .transaction(req)
            .run(deleteOrder(req.data))
            .then((resolve, reject) => processDeletion(req, resolve, reject))
            .catch((err) => {
                console.log(err);
                req.error(err.code, err.message);
            });

        console.log("Before End", result);

        return result;

    });

    //******FUNCTIONS******//        
    srv.on("getClientTaxRate", async (req) => {

        // NO server "side-effect"
        let { clientEmail } = req.data;
        let db = srv.transaction(req);

        let results = await db
            .read(Orders, ["Country_code"])
            .where({ ClientEmail: clientEmail });

        console.log(results[0]);

        // tax determination
        switch (results[0].Country_code) {

            case 'ES':
                return 21.5;
            case "UK":
                return 24.6;
            default:
                break;
        }

    });

    //*******ACTIONS*******//    
    srv.on("cancelOrder", async (req) => {

        let returnOrder = {
            status: "",
            message: ""
        };

        let { clientEmail } = req.data;
        let db = srv.transaction(req);

        let readResult = await db
            .read(Orders, ["FirstName", "LastName", "Approved"])
            .where({ ClientEmail: clientEmail });

        console.log(readResult);

        if (readResult[0].Approved == false) {

            // eslint-disable-next-line no-unused-vars
            let updateResult = await db
                .update(Orders)
                .set({ Status: "C" })
                .where({ ClientEmail: clientEmail });

            returnOrder.status = "Succeded"
            returnOrder.message = `The Order placed by ${readResult[0].FirstName} ${readResult[0].LastName} was canceled.`

        } else {

            returnOrder.status = "Failed"
            returnOrder.message = `The Order placed by ${readResult[0].FirstName} ${readResult[0].LastName} was not canceled (It was already approved).`

        }

        console.log("Action cancelOrder executed");

        return returnOrder;

    });

};
