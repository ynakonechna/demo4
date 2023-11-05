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

    app.get("/specialties", function(req, res){
        if (req.session.username) {
            pool.query("SELECT\n" +
            "specialties.Id_specialty,\n" +
            "specialties.code_specialty,\n" +
            "specialties.name\n" +
            "FROM\n" +
        
            "specialties\n", function(err, data) {
                if (err) return console.log(err);
    
                res.render("specialties.hbs", {
                    specialties: data,
                    zagolovok: zagolovok
                });
            })
        } else {
            res.redirect("/");
        }
        
    });
    
    app.get("/specialties_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            res.render("specialties_c.hbs",{
                zagolovok: zagolovok
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/specialties_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const code_specialty = req.body.code_specialty;
            const name = req.body.name;
            pool.query("INSERT INTO specialties (code_specialty, name) VALUES (?,?)",
            [code_specialty, name], function(err, data) {
                if(err) return console.log(err);
                res.redirect("/specialties");
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.get("/specialties_e/:Id_specialty", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_specialty = req.params.Id_specialty;
            pool.query("SELECT\n" +
            "specialties.Id_specialty, \n" +
            "specialties.code_specialty, \n" +
            "specialties.name\n" +
            "FROM\n" +
            "specialties WHERE Id_specialty=?", [Id_specialty], function(err, data) {
                if(err) return console.log(err);
                res.render("specialties_e.hbs", {
                    specialties: data[0],
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/specialties_e", urlencodedParser, function (req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const code_specialty = req.body.code_specialty;
            const name = req.body.name;
            const Id_specialty = req.body.Id_specialty;
        
            pool.query("UPDATE specialties SET code_specialty=?, name=? WHERE Id_specialty=?",
            [code_specialty, name, Id_specialty], function(err, data) {
                if(err) return console.log(err);
                res.redirect("/specialties");
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/delete/:Id_specialty", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_specialty = req.params.Id_specialty;
    
            pool.query("DELETE FROM specialties WHERE Id_specialty=?", [Id_specialty], function(err, data){
                if(err) return console.log(err);
                res.redirect("/specialties");
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });

}