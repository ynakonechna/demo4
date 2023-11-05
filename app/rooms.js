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

    app.get("/rooms/:Id_hostel", function(req, res){
        if (req.session.username) {
            const Id_hostel = req.params.Id_hostel;
            pool.query("SELECT \
            rooms.Id_room, \
            hostels.number, \
            rooms.number_room, \
            rooms.number_seats, \
            rooms.characteristic, \
            DATE_FORMAT(rooms.date_last_repair, '%d.%m.%Y') AS date_last_repair, \
            hostels.Id_hostel \
            FROM \
            hostels \
            Inner Join rooms ON hostels.Id_hostel = rooms.Id_hostel WHERE hostels.Id_hostel = ?",  [Id_hostel], function(err, data) {
                    if (err) return console.log(err);
                    pool.query("SELECT number FROM  hostels WHERE Id_hostel = ?", [Id_hostel], function(err, data2) {
                        if(err) return console.log(err);
                
                
                        res.render("rooms.hbs", {
                            rooms: data,
                            zagolovok: zagolovok,
                            hostel_number: data2[0].number
                        });
                    });
                    
                })
        }  else {
            res.redirect("/");
        }
        
    });


    app.get("/rooms_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            pool.query("SELECT\n" +
                "hostels.Id_hostel,\n" +
                "hostels.number\n"+
                "FROM\n" +
                "hostels\n", function(err, data) {
                if(err) return console.log(err);
                res.render("rooms_c.hbs", {
                    hostels: data,
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/rooms_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_hostel = req.body.Id_hostel;
            const number_room = req.body.number_room;
            const number_seats = req.body.number_seats;
            const characteristic = req.body.characteristic;
            const date_last_repair = req.body.date_last_repair;
            pool.query("INSERT INTO rooms (Id_hostel, number_room, number_seats, characteristic, date_last_repair ) VALUES (?,?,?,?,?)",
            [Id_hostel, number_room, number_seats, characteristic, date_last_repair], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/rooms/${Id_hostel}`);
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.get("/rooms_e/:Id_room", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_room = req.params.Id_room;
            pool.query("SELECT\n" +
            "rooms.Id_room, \n" +
            "rooms.Id_hostel, \n" +
            "rooms.number_room, \n" +
            "rooms.number_seats, \n" +
            "rooms.characteristic, \n" +
            "DATE_FORMAT(rooms.date_last_repair, '%Y-%m-%d') AS date_last_repair\n" +
            "FROM\n" +
            "rooms WHERE Id_room=?", [Id_room], function(err, data) {
                if(err) return console.log(err);
                pool.query("SELECT\n" +
                "hostels.Id_hostel,\n" +
                "hostels.number\n"+
                "FROM\n" +
                "hostels\n", function(err, data2) {
                if(err) return console.log(err);
        
        
                res.render("rooms_e.hbs", {
                    rooms: data[0],
                    hostels: data2,
                    zagolovok: zagolovok
                });
            });
        });
        } else {
            res.redirect("/visiting");
        }
        
    });
    
    app.post("/rooms_e", urlencodedParser, function (req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_hostel = req.body.Id_hostel
            const number_room = req.body.number_room;
            const number_seats = req.body.number_seats;
            const characteristic = req.body.characteristic;
            const date_last_repair = req.body.date_last_repair;
            const Id_room = req.body.Id_room;
        
            pool.query("UPDATE rooms SET Id_hostel=?, number_room=?, number_seats=?, characteristic=?, date_last_repair=? WHERE Id_room=?",
            [Id_hostel, number_room, number_seats, characteristic, date_last_repair, Id_room], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/rooms/${Id_hostel}`);
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.post("/rooms_d/:Id_room/hostel/:Id_hostel", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_room = req.params.Id_room;
            const Id_hostel = req.params.Id_hostel;
        
            pool.query("DELETE FROM rooms WHERE Id_room=?", [Id_room], function(err, data){
                if(err) return console.log(err);
                res.redirect(`/rooms/${Id_hostel}`);
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });


}