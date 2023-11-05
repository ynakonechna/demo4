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
    let number_room = ""
    let Id_room = ""
    app.get("/students/number_room/:number_room/id_room/:Id_room", function(req,res){
        if (req.session.username) {
            number_room = req.params.number_room;
            Id_room = req.params.Id_room;
    
            pool.query("SELECT \
            students.Id_student, \
            students.pib, \
            rooms.number_room, \
            specialties.name, \
            students.phone, \
            students.e_mail, \
            students.adress, \
            students.foreigner, \
            students.year_entry, \
            DATE_FORMAT(students.date_leave, '%d.%m.%Y') AS date_leave, \
            specialties.Id_specialty, \
            rooms.Id_room \
            FROM \
            rooms \
            Inner Join students ON students.Id_room = rooms.Id_room \
            Inner Join specialties ON students.Id_specialty = specialties.Id_specialty \
            WHERE \
            rooms.number_room =  ?", [number_room], function(err, data) {
                if(err) return console.log(err);
                res.render("students.hbs", {
                    students: data,
                    number_room: number_room,
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/");
        }
    });

    app.get("/students_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            pool.query("SELECT specialties.Id_specialty, specialties.name FROM specialties", function(err, data2) {
                if(err) return console.log(err);
                res.render("students_c.hbs", {
                    number_room: number_room,
                    specialties: data2,
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
    });
    
    app.post("/students_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_specialty = req.body.Id_specialty;
            const pib = req.body.pib;
            const phone = req.body.phone;
            const e_mail = req.body.e_mail;
            const adress = req.body.adress;
            const foreigner = req.body.foreigner;
            const year_entry = req.body.year_entry;
            const date_leave = req.body.date_leave;
            const number_room = req.body.number_room;

            let bool_foreigner = false

            if (foreigner === "on") {
                bool_foreigner = true;
            }

            pool.query("INSERT INTO students (Id_room, Id_specialty, pib, phone, e_mail, adress, foreigner, year_entry, date_leave) VALUES (?,?,?,?,?,?,?,?,?)",
            [Id_room, Id_specialty, pib, phone, e_mail, adress, bool_foreigner, year_entry, date_leave], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/students/number_room/${number_room}/id_room/${Id_room}`);
            });
        } else {
            res.redirect("/visiting");
        }
    });

    app.get("/students_e/:Id_student", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_student = req.params.Id_student;
            pool.query("SELECT\n" +
            "students.Id_student, \n" +
            "students.Id_room, \n" +
            "rooms.number_room, \n" +
            "specialties.Id_specialty, \n" +
            "specialties.name, \n" +
            "students.pib, \n" +
            "students.phone, \n" +
            "students.e_mail, \n" +
            "students.adress, \n" +
            "students.foreigner, \n" +
            "students.year_entry, \n" +
            "DATE_FORMAT(students.date_leave, '%Y-%m-%d') AS date_leave\n" +
            "FROM\n" +
            "students\n" +
            "Inner Join rooms ON students.Id_room = rooms.Id_room  Inner Join specialties ON specialties.Id_specialty = students.Id_specialty WHERE Id_student=?", [Id_student], function(err, data) {
                if(err) return console.log(err2);
                if (data[0].foreigner == 1) {
                    data[0].foreigner = "checked"
                } else {
                    data[0].foreigner = "unchecked"
                }

                pool.query("SELECT specialties.Id_specialty, specialties.name FROM specialties", function(err2, data2) {
                    if(err2) return console.log(err);
                    res.render("students_e.hbs", {
                        students: data[0],
                        specialties: data2,
                        zagolovok: zagolovok
                    });
                });
            });
        } else {
            res.redirect("/visiting");
        }
    });
    
    app.post("/students_e", urlencodedParser, function (req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_room = req.body.Id_room
            const Id_specialty = req.body.Id_specialty;
            const pib = req.body.pib;
            const e_mail = req.body.e_mail;
            const adress = req.body.adress;
            const foreigner = req.body.foreigner;
            const year_entry = req.body.year_entry;
            const date_leave = req.body.date_leave;
            const Id_student = req.body.Id_student;
            let bool_foreigner = false

            if (foreigner === "on") {
                bool_foreigner = true;
            }

        
            pool.query("UPDATE students SET Id_room=?, Id_specialty=?, pib=?, e_mail=?, adress=?, foreigner=?, year_entry=?,date_leave=? WHERE Id_student=?",
            [Id_room, Id_specialty, pib, e_mail, adress, bool_foreigner, year_entry, date_leave, Id_student], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/students/number_room/${number_room}/id_room/${Id_room}`);
            });
        } else {
            res.redirect("/visiting");
        }
    });

    app.post("/students_d/:Id_student", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_student = req.params.Id_student;
    
            pool.query("DELETE FROM students WHERE Id_student=?", [Id_student], function(err, data){
                if(err) return console.log(err);
                res.redirect(`/students/number_room/${number_room}/id_room/${Id_room}`);
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });

    app.get("/order/:Id_student", function(req, res){
        if (req.session.username) {
            const Id_student = req.params.Id_student;
            pool.query("SELECT \
            students.pib, \
            specialties.name, \
            rooms.Id_hostel, \
            students.Id_room \
            FROM \
            students \
            Inner Join specialties ON students.Id_specialty = specialties.Id_specialty \
            Inner Join rooms ON rooms.Id_room = students.Id_room \
            WHERE students.Id_student=?", [Id_student], function(err, data) {
                if(err) return console.log(err);
                res.render("order.hbs", {
                    students: data[0],
                    zagolovok: zagolovok,
                    boostrap_v: true
    
                });
            });
        } else {
            res.redirect("/");
        }
   
    }); 

}