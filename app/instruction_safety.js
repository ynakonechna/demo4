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

    app.get("/instruction_safety", function(req, res){
        if (req.session.username) {
            pool.query("SELECT \
                instruction_safety.Id_instruction, \
                managers.pib, \
                DATE_FORMAT(instruction_safety.date, '%d.%m.%Y') AS date, \
                instruction_safety.type_instruction, \
                instruction_safety.Id_manager \
                FROM \
                instruction_safety \
                Inner Join managers ON instruction_safety.Id_manager = managers.Id_manager \
                ORDER BY \
                instruction_safety.Id_instruction DESC", function(err, data) {
                if (err) return console.log(err);

                res.render("instruction_safety.hbs", {
                    zagolovok: zagolovok,
                    instruction_safety: data
                });
            })
        } else {
            res.redirect("/");
        }
        
    });


    app.get("/instruction_safety_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            pool.query("SELECT\n" +
                "managers.Id_manager,\n" +
                "managers.pib\n"+
                "FROM\n" +
                "managers\n", function(err, data) {
                if(err) return console.log(err);
                res.render("instruction_safety_c.hbs", {
                    managers: data,
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/instruction_safety_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_manager = req.body.Id_manager;
            const date = req.body.date;
            const type_instruction = req.body.type_instruction;
            pool.query("INSERT INTO instruction_safety (Id_manager, date, type_instruction) VALUES (?,?,?)",
            [Id_manager, date, type_instruction], function(err, data) {
                if(err) return console.log(err);
                res.redirect('/instruction_safety');
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.get("/instruction_safety_e/:Id_instruction", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_instruction = req.params.Id_instruction;
            pool.query("SELECT\n" +
            "instruction_safety.Id_instruction, \n" +
            "instruction_safety.Id_manager, \n" +
            "DATE_FORMAT(instruction_safety.date, '%Y-%m-%d') AS date, \n" +
            "instruction_safety.type_instruction \n" +
            
            "FROM\n" +
            "instruction_safety WHERE Id_instruction=?", [Id_instruction], function(err, data) {
                if(err) return console.log(err);
                pool.query("SELECT\n" +
                "managers.Id_manager,\n" +
                "managers.pib\n"+
                "FROM\n" +
                "managers\n", function(err, data2) {
                if(err) return console.log(err);
        
        
                res.render("instruction_safety_e.hbs", {
                    instruction_safety: data[0],
                    managers: data2,
                    zagolovok: zagolovok
                });
            });
        });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/instruction_safety_e", urlencodedParser, function (req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_manager = req.body.Id_manager;
            const date = req.body.date;
            const type_instruction = req.body.type_instruction;
            const Id_instruction = req.body.Id_instruction;
        
            pool.query("UPDATE instruction_safety SET Id_manager=?, date=?, type_instruction=? WHERE Id_instruction=?",
            [Id_manager, date, type_instruction, Id_instruction], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/instruction_safety`);
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.post("/instruction_safety_d/:Id_instruction", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_instruction = req.params.Id_instruction;
    
            pool.query("DELETE FROM instruction_safety WHERE Id_instruction=?", [Id_instruction], function(err, data){
                if(err) return console.log(err);
                res.redirect(`/instruction_safety`);
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });


}