const mysql = require("mysql2");
const express = require("express");
const bodyParser = require("body-parser");
const hbs = require("hbs");
const expressHbs = require("express-handlebars");
const path = require('path')
const app = express();
const urlencodedParser = bodyParser.urlencoded({extended: false});

app.use(express.static('img'))

app.engine("hbs", expressHbs(
    {
        layoutsDir: "views",
        defaultLayout: "index",
        extname: "hbs",
        partialsDir: "views"
    }
))
app.set("view engine", "hbs");

const zagolovok = "Облік гуртожитків"

function createStore() {
    const pool = mysql.createPool({
        connectionLimit: 5,
        host: process.env.PG_HOST,
        user: process.env.PG_USERNAME,
        database: process.env.PG_DATABASE,
        password: process.env.PG_PASSWORD
    });
    global.pool =pool
}

global.zagolovok =zagolovok

var cookieParser = require("cookie-parser");
var session = require("express-session");

app.use(bodyParser.json())

var store = createStore()

app.use(cookieParser())
app.use(session({
    store: store,
    resave: false,
    saveUninitialized: true,
    secret: 'supersecret'
}))

app.post("/login", function(req, res){

    var foundUser
    var e_mail=req.body.username
    var parol=req.body.password
    //console.log(req.body)
    pool.query("SELECT\n" +
        "managers.e_mail,\n" +
        "managers.parol,\n" +
        "managers.prava\n" +
         "FROM\n" +
         "managers\n" +
         "WHERE\n" +
         "managers.e_mail = ? AND\n" + 
         "managers.parol = ?", [e_mail, parol] ,function(err, data) {
         if(err) return console.log(err);   
         if (data.length>0) {
             foundUser = data[0].e_mail
             global.prava = data[0].prava
         }     
         console.log(global.prava);

    if (foundUser !== undefined) {
        req.session.username = foundUser
        console.log(req.session.username);
        res.send(req.session.username)
        
    } else {
        console.log('Error 2');
    }
    });
});

app.get("/logout", function (req, res){
    req.session.username =''
    res.redirect("/");
})


app.get("/", function(req, res){
    res.render("start.hbs", {
        zagolovok: zagolovok
    });

});


const PORT = process.env.PORT || 3000
app.listen(PORT, function(){
    console.log("Сервер");
});

const specialties = require('./specialties')
specialties(app)

const managers = require('./managers')
managers(app)

const hostels = require('./hostels')
hostels(app)

const rooms = require('./rooms')
rooms(app)

const students = require('./students')
students(app)

const profit = require('./profit')
profit(app)

const payment = require('./payment')
payment(app)

const debt = require('./debt')
debt(app)

const visiting = require('./visiting')
visiting(app)

const instruction_safety = require('./instruction_safety')
instruction_safety(app)

const students_instruction = require('./students_instruction')
students_instruction(app)

app.get("/foreigners", function(req, res){
    if (req.session.username && global.prava=='admin') {
        pool.query("SELECT \
        students.pib, \
        rooms.number_room, \
        students.phone, \
        students.adress \
        FROM \
        students \
        Inner Join rooms ON students.Id_room = rooms.Id_room \
        WHERE \
        students.foreigner =  '1'", function(err, data) {
            if(err) return console.log(err);
            res.render("foreigners.hbs", {
                foreigners: data,
                zagolovok: zagolovok,
                boostrap_v: true
            });
        });
    } else {
        res.redirect("/visiting");
    }
    
});

app.get("/students_late", function(req, res){
    if (req.session.username && global.prava=='admin') {
        pool.query("SELECT \
        students.pib, \
        rooms.number_room, \
        TIME(visiting.time_e) as time_e, \
        students.phone \
        FROM \
        visiting \
        Inner Join students ON visiting.Id_student = students.Id_student \
        Inner Join rooms ON students.Id_room = rooms.Id_room \
        WHERE \
        TIME(visiting.time_e) BETWEEN  '00:00:00' AND '06:00:00' \
        ORDER BY \
        visiting.time_e DESC \
        ", function(err, data) {
            if(err) return console.log(err);
            res.render("students_late.hbs", {
                students_late: data,
                zagolovok: zagolovok,
                boostrap_v: true
            });
        });
    } else {
        res.redirect("/visiting");
    }
    
});

app.get("/rooms_repair", function(req, res){
    if (req.session.username && global.prava=='admin') {
        pool.query("SELECT \
        hostels.number, \
        rooms.number_room, \
        DATE_FORMAT(rooms.date_last_repair, '%Y-%m-%d') AS date_last_repair \
        FROM \
        rooms \
        Inner Join hostels ON rooms.Id_hostel = hostels.Id_hostel \
        ORDER BY \
        rooms.date_last_repair ASC \
        LIMIT 10", function(err, data) {
            if(err) return console.log(err);
            res.render("rooms_repair.hbs", {
                rooms_repair: data,
                zagolovok: zagolovok,
                boostrap_v: true
            });
        });
    } else {
        res.redirect("/visiting");
    }
    
});

app.get("/borg", function(req, res){
    if (req.session.username && global.prava=='admin') {
        pool.query("SELECT \
        students.pib, \
        students.Id_student, \
        Sum(profit.amount) AS profit_amount, \
        rooms.number_room, \
        hostels.number \
        FROM \
        profit \
        Inner Join students ON profit.Id_student = students.Id_student \
        Inner Join rooms ON students.Id_room = rooms.Id_room \
        Inner Join hostels ON rooms.Id_hostel = hostels.Id_hostel \
        GROUP BY \
        students.pib, \
        students.Id_student \
        ORDER BY students.Id_student", function(err, data) {
            if(err) return console.log(err);
            pool.query("SELECT Id_student, SUM(amount) AS payment_amount FROM payment GROUP BY Id_student", function(err2, data2){
                if(err) return console.log(err);
                borgArray = []

                for (let i = 0; i < data.length; i++) {
                    let data_student_id = data[i].Id_student
                    for (let j = 0; j < data2.length; j++) {
                        let data2_student_id = data2[j].Id_student
                        if (data_student_id == data2_student_id) {
                            data[i].payment_amount = data2[j].payment_amount
                        
                            let nar = parseInt(data[i].profit_amount)
                            let opl = parseInt(data2[j].payment_amount)

                            if (nar !== nar) {
                                nar = 0
                            } 

                            if (opl !== opl) {
                                opl = 0
                            } 

                            let debt = Math.abs(nar) - Math.abs(opl)
                            data[i].debt = debt

                            if (debt != 0) {
                                borgArray.push(data[i])
                            }
                            break;
                        }
                    }
                }

                res.render("borg.hbs", {
                    borg: borgArray,
                    zagolovok: zagolovok,
                    boostrap_v: true
                });
            })
        });
    } else {
        res.redirect("/visiting");
    }
    
});
