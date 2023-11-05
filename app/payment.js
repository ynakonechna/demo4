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
    app.get("/payment/:Id_student", function(req, res){
        if (req.session.username) {
            Id_student = req.params.Id_student;
            pool.query("SELECT \
            payment.Id_payment, \
            DATE_FORMAT(payment.date_payment, '%d.%m.%Y') AS date_payment, \
            payment.amount, \
            payment.appointment, \
            students.Id_student \
            FROM \
            payment \
            Inner Join students ON students.Id_student = payment.Id_student WHERE students.Id_student = ?",  [Id_student], function(err, data) {
                    if (err) return console.log(err);
                    pool.query("SELECT pib FROM students WHERE Id_student = ?", [Id_student], function(err, data2) {
                        if(err) return console.log(err);
                
                
                        res.render("payment.hbs", {
                            payment: data,
                            zagolovok: zagolovok,
                            pib_s: data2[0].pib
                        });
                    });
                    
                }) 
        } else {
            res.redirect("/");
        }
        
    });

    app.get("/payment_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            pool.query("SELECT\n" +
                "students.Id_student,\n" +
                "students.pib\n"+
                "FROM\n" +
                "students WHERE Id_student = ?\n", [Id_student], function(err, data) {
                if(err) return console.log(err);
                res.render("payment_c.hbs", {
                    student: data[0],
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.post("/payment_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_student = req.body.Id_student;
            const date_payment = req.body.date_payment;
            const amount = req.body.amount;
            const appointment = req.body.appointment;
            pool.query("INSERT INTO payment (Id_student, date_payment, amount, appointment) VALUES (?,?,?,?)",
            [Id_student, date_payment, amount, appointment], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/payment/${Id_student}`);
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.post("/payment_d/:Id_payment", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_payment = req.params.Id_payment;
    
            pool.query("DELETE FROM payment WHERE Id_payment=?", [Id_payment], function(err, data){
                if(err) return console.log(err);
                res.redirect(`/payment/${Id_student}`);
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });

}