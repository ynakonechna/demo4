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

    app.get("/managers", function(req, res){
        if (req.session.username) {
            pool.query("SELECT\n" +
                "managers.Id_manager,\n" +
                "managers.pib,\n" +
                "managers.phone,\n" +
                "managers.e_mail\n" +
                "FROM\n" +
            
                "managers\n", function(err, data) {
                    if (err) return console.log(err);
        
                    res.render("managers.hbs", {
                        managers: data,
                        zagolovok: zagolovok
                    });
                })
        } else {
            res.redirect("/");
        }
        
    });
    
    app.get("/managers_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            res.render("managers_c.hbs",{
                zagolovok: zagolovok
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/managers_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const pib = req.body.pib;
            const phone = req.body.phone;
            const e_mail = req.body.e_mail;
            pool.query("INSERT INTO managers (pib, phone, e_mail) VALUES (?,?,?)",
            [pib, phone, e_mail], function(err, data) {
                if(err) return console.log(err);
                res.redirect("/managers");
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.get("/managers_e/:Id_manager", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_manager = req.params.Id_manager;
            pool.query("SELECT\n" +
            "managers.Id_manager, \n" +
            "managers.pib, \n" +
            "managers.phone, \n" +
            "managers.e_mail\n" +
            "FROM\n" +
            "managers WHERE Id_manager=?", [Id_manager], function(err, data) {
                if(err) return console.log(err);
                res.render("managers_e.hbs", {
                    managers: data[0],
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/managers_e", urlencodedParser, function (req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const pib = req.body.pib;
            const phone = req.body.phone;
            const e_mail = req.body.e_mail;
            const Id_manager = req.body.Id_manager;
        
            pool.query("UPDATE managers SET pib=?, phone=?, e_mail=? WHERE Id_manager=?",
            [pib, phone, e_mail, Id_manager], function(err, data) {
                if(err) return console.log(err);
                res.redirect("/managers");
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/managers_d/:Id_manager", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_manager = req.params.Id_manager;
    
            pool.query("DELETE FROM managers WHERE Id_manager=?", [Id_manager], function(err, data){
                if(err) return console.log(err);
                res.redirect("/managers");
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });

}