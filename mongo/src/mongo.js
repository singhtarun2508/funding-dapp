const mongoose = require("mongoose")
mongoose.connect("mongodb://localhost:27017/tarundb")
.then(()=>console.log("connection created"))
.catch((err)=>console.log(err))

const schema =new  mongoose.Schema({
    name:{
        type:String,
        required:true
    },
    username:{
        type:String,
        required:true,
        unique:true
    },
    email:{
        type:String,
        required:true,
        unique:true
    },
    phone:{
        type:Number,
        required:true,
        unique:true
    },
    password:{
        type:String,
        required:true
    },
    confirmpassword:{
        type:String,
        required:true
    }  
})

const Student =new mongoose.model("Student",schema);

const add= async()=>{
const s1= new Student({
    name:"Tarun",
    username:"tarun123",
    email:"this@mail",
    phone:8920,
    password:"hey",
    confirmpassword:"hey"
})
const result = await s1.save();
console.log(result)
}
// add();
module.exports= Student;