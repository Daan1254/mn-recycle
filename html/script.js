$(window).ready(() => {
    $(".container").hide()
    
})



window.addEventListener("message", (message) => {
    if (message.data.action == 'open') {
        opendashboard(message.data)
    }
})


const opendashboard = (data) => {
    console.log(JSON.stringify(data)  )
    $(".current_salary").html((parseInt(data.packagesDone) * parseInt(data.priceperPackage) ))
    $(".container").fadeIn(250)
}