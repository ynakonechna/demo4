const mysql = require("mysql2");
const express = require("express");
const bodyParser = require("body-parser");
const hbs = require("hbs");
const expressHbs = require("express-handlebars");
const path = require('path')
const app = express();
const urlencodedParser = bodyParser.urlencoded({extended: false});

zagolovok=global.zagolovok
pool=global.pool

module.exports = function(app) {
    let Id_student = ""
    app.get("/debt/:Id_student", function(req, res){
        if (req.session.username && global.prava=='admin') {
            Id_student = req.params.Id_student;
            pool.query("SELECT \
            SUM(0-profit.amount) AS profit_amount \
            FROM \
            profit \
            WHERE \
            profit.Id_student = ? \
            UNION \
            SELECT \
            SUM(payment.amount) AS payment_amount \
            FROM \
            payment \
            WHERE \
            payment.Id_student =  ?",  [Id_student, Id_student], function(err, data) {
                    if (err) return console.log(err);
                    pool.query("SELECT pib FROM students WHERE Id_student = ?", [Id_student], function(err, data2) {
                        if(err) return console.log(err);

                        let arrayStat = []

                        data.forEach( i => {
                            arrayStat.push(i.profit_amount)
                        });

                        let nar = parseInt(arrayStat[0])
                        let opl = parseInt(arrayStat[1])

                        if (nar !== nar) {
                            nar = 0
                        } 

                        if (opl !== opl) {
                            opl = 0
                        } 


                        let debt = Math.abs(nar) - Math.abs(opl)

                        res.render("debt.hbs", {
                            profit_amount:  Math.abs(nar),
                            payment_amount:  Math.abs(opl),
                            zagolovok: zagolovok,
                            pib_s: data2[0].pib,
                            debt: debt
                        });
                    });
                    
                })
        } else {
            res.redirect("/visiting");
        }
        
    });

}