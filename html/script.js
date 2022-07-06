$(window).ready(() => {
    $(".container").hide()
    
})



window.addEventListener("message", (message) => {
    if (message.data.action == 'open') {

        opendashboard(message.data)
    }
})


const uitbetalen = () => {
    $.post("https://mn-recycle/yetoch")
    $.post('https://mn-recycle/close')
    $(".container").fadeOut(250);
}


const opendashboard = (data) => {
    $("#current_salary").html((data.packagesDone * data.payoutperPackage || 0))
    $("#total_pickups").html(data.playerData.totalPickups)
    $("#total_money").html("&euro; " + data.playerData.totalPickups * data.payoutperPackage)

    if (data.levelConfig[data.playerData.level] == null) {
        console.log("Max")
        let percentage = 100
        $(".right-inner-progressValue").html("100%")
        $("#cur_level").html("MAX")
        $(".container").fadeIn(250)
        $(".progressinner").animate({
            width: "100%"
        }, 1000)
        $(".next-item").hide()
        $(".right-inner-itemname").hide()
        $(".right-inner-nextitem").html("Je hebt alle items unlockt!")
    } else {
        let currentXP = data.levelConfig[data.playerData.level].XPneededToLevel - data.playerData.XP
        let totalXP = data.levelConfig[data.playerData.level].XPneededToLevel - data.levelConfig[data.playerData.level - 1].XPneededToLevel
        let percentage = (currentXP / totalXP) * 100
        $("#cur_level").html(data.playerData.level)
        getImgsource((item) => {
            $(".next-item").attr("src", "./img/" + item.img)
            $(".right-inner-itemname").html(item.itemname)
        }, data.levelConfig[data.playerData.level].itemsUnlock)
        $(".right-inner-progressValue").html(100 - Math.round(percentage) + "%")
        console.log(Math.round(percentage))
        $(".container").fadeIn(250)
        $(".progressinner").animate({
            width: (100 - Math.round(percentage)) + "%"
        }, 1000)
    }

}


const getImgsource = (callback, items) => {
    items.forEach(item => {
        if (item.new) {
            callback(item) 
        }
    })
}

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27:
            $.post('https://mn-recycle/close')
            $(".container").fadeOut(250);
        break; 
    }
})