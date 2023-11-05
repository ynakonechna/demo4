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
    let Id_instruction

    app.get("/students_instruction/:Id_instruction", function(req, res){
        if (req.session.username) {
            Id_instruction = req.params.Id_instruction;
            pool.query("SELECT \
            students_instruction.Id_st_instruction, \
            instruction_safety.Id_instruction, \
            students.pib, \
            students_instruction.additionally \
            FROM \
            instruction_safety \
            Inner Join students_instruction ON instruction_safety.Id_instruction = students_instruction.Id_instruction \
            Inner Join students ON students_instruction.Id_student = students.Id_student \
            WHERE instruction_safety.Id_instruction = ?",  [Id_instruction], function(err, data) {
                    if (err) return console.log(err);
                    pool.query("SELECT DATE_FORMAT(date, '%d.%m.%Y') AS date FROM  instruction_safety WHERE Id_instruction = ?", [Id_instruction], function(err, data2) {
                        if(err) return console.log(err);
                
                
                        res.render("students_instruction.hbs", {
                            students_instruction: data,
                            zagolovok: zagolovok,
                            date_i: data2[0].date
                        });
                    });
                    
                })
        } else {
            res.redirect("/");
        }
        
    });


    app.get("/students_instruction_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            pool.query("SELECT\n" +
                "students.Id_student,\n" +
                "students.pib\n"+
                "FROM\n" +
                "students\n", function(err, data) {
                if(err) return console.log(err);
                res.render("students_instruction_c.hbs", {
                    students: data,
                    Id_instruction: Id_instruction,
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
    });
    
    app.post("/students_instruction_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_instruction = req.body.Id_instruction;
            const Id_student = req.body.Id_student;
            const additionally = req.body.additionally;
            pool.query("INSERT INTO students_instruction (Id_instruction, Id_student, additionally) VALUES (?,?,?)",
            [Id_instruction, Id_student, additionally], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/students_instruction/${Id_instruction}`);
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.get("/students_instruction_e/:Id_st_instruction", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_st_instruction = req.params.Id_st_instruction;
            pool.query("SELECT\n" +
            "students_instruction.Id_st_instruction, \n" +
            "students_instruction.Id_instruction, \n" +
            "students_instruction.Id_student, \n" +
            "students_instruction.additionally \n" +
            "FROM\n" +
            "students_instruction WHERE Id_st_instruction=?", [Id_st_instruction], function(err, data) {
                if(err) return console.log(err);
                pool.query("SELECT\n" +
                "students.Id_student,\n" +
                "students.pib\n"+
                "FROM\n" +
                "students\n", function(err, data2) {
                if(err) return console.log(err);
        
                res.render("students_instruction_e.hbs", {
                    students_instruction: data[0],
                    students: data2,
                    zagolovok: zagolovok
                });
            });
        });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/students_instruction_e/:Id_st_instruction", urlencodedParser, function (req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_st_instruction = req.params.Id_st_instruction;
            
            const Id_instruction = req.body.Id_instruction
            const Id_student = req.body.Id_student;
            const additionally = req.body.additionally;
        
            pool.query("UPDATE students_instruction SET Id_instruction=?, Id_student=?, additionally=? WHERE Id_st_instruction=?",
            [Id_instruction, Id_student, additionally, Id_st_instruction], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/students_instruction/${Id_instruction}`);
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.post("/students_instruction_d/:Id_st_instruction", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_st_instruction = req.params.Id_st_instruction;
    
            pool.query("DELETE FROM students_instruction WHERE Id_st_instruction=?", [Id_st_instruction], function(err, data){
                if(err) return console.log(err);
                res.redirect(`/students_instruction/${Id_instruction}`);
        
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

}