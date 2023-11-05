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

    app.get("/hostels", function(req, res){
        if (req.session.username) {
            pool.query("SELECT hostels.Id_hostel, managers.pib, hostels.number, hostels.adress, managers.Id_manager FROM managers Inner Join hostels ON managers.Id_manager = hostels.Id_manager", function(err, data) {
                if (err) return console.log(err);
    
                res.render("hostels.hbs", {
                    hostels: data,
                    zagolovok: zagolovok
                });
            })
        } else {
            res.redirect("/");
        }
    });
    
    app.get("/hostels_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            pool.query("SELECT\n" +
                "managers.Id_manager,\n" +
                "managers.pib\n"+
                "FROM\n" +
                "managers\n", function(err, data) {
                if(err) return console.log(err);
                res.render("hostels_c.hbs", {
                    managers: data,
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/hostels_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_manager = req.body.Id_manager;
            const number = req.body.number;
            const adress = req.body.adress;
            pool.query("INSERT INTO hostels (Id_manager, number, adress) VALUES (?,?,?)",
            [Id_manager, number, adress], function(err, data) {
                if(err) return console.log(err);
                res.redirect("/hostels");
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.get("/hostels_e/:Id_hostel", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_hostel = req.params.Id_hostel;
            pool.query("SELECT\n" +
            "hostels.Id_hostel, \n" +
            "hostels.Id_manager, \n" +
            "hostels.number, \n" +
            "hostels.adress\n" +
            "FROM\n" +
            "hostels WHERE Id_hostel=?", [Id_hostel], function(err, data) {
                if(err) return console.log(err);
                pool.query("SELECT\n" +
                "managers.Id_manager,\n" +
                "managers.pib\n"+
                "FROM\n" +
                "managers\n", function(err, data2) {
                if(err) return console.log(err);
        
        
                res.render("hostels_e.hbs", {
                    hostels: data[0],
                    managers: data2,
                    zagolovok: zagolovok
                });
            });
        });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/hostels_e", urlencodedParser, function (req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_manager = req.body.Id_manager
            const number = req.body.number;
            const adress = req.body.adress;
            const Id_hostel = req.body.Id_hostel;
        
            pool.query("UPDATE hostels SET Id_manager=?, number=?, adress=? WHERE Id_hostel=?",
            [Id_manager, number, adress, Id_hostel], function(err, data) {
                if(err) return console.log(err);
                res.redirect("/hostels");
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/hostels_d/:Id_hostel", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_hostel = req.params.Id_hostel;
    
            pool.query("DELETE FROM hostels WHERE Id_hostel=?", [Id_hostel], function(err, data){
                if(err) return console.log(err);
                res.redirect("/hostels");
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });

}