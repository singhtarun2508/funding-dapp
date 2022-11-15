const express = require ("express")
const path =require ("path")
const app =express();
const hbs =require("hbs");
const Student = require("./mongo");
const { urlencoded } = require("express");
require("./mongo")





const add= async()=>{
    const s1= new Student({
        name:"Tarun",
        username:"tarun23",
        email:"thi@mail",
        phone:890,
        password:"hey",
        confirmpassword:"hey"
    })
    const result = await s1.save();
    console.log(result)
    }
    // add();



// app.use(express.json)
app.use(urlencoded({extended:false}))


port= process.env.port||8000;

const viewpath=path.join(__dirname,"../templates/views")
const partialpath=path.join(__dirname,"../templates/partials")
const staticPath= path.join(__dirname,"../public")

app.set("views", viewpath)
app.set("view engine", "hbs");
app.get("/", (req,res)=>{
    res.render("index");
})

hbs.registerPartials(partialpath)
app.use(express.static(staticPath))

app.get("/", (req,res)=>{
    res.send("hello")
})

app.post("/stu",async (req,res)=>{
    const password=(req.body.password)
    const confirmpassword=(req.body.confirmpassword)


    if(password===confirmpassword){
        const s1= new Student({
        name:req.body.name,
        username:req.body.username,
        email:req.body.email,
        phone:req.body.phone,
        password:req.body.password,
        confirmpassword:req.body.confirmpassword
        })

        const result= await s1.save()
        res.render("index");    }
    else{
        res.send("password not matching")
    }
})

app.listen(port,()=>{
    console.log("listening")
})