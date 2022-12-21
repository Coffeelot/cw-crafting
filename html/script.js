let cwCrafting = {}
let Recipies = []
let Categories = []
let currentRecipie = {}
let currentAdId = -1

$(document).ready(function(){
    console.log('lol crafting')
    $('.crafting-container').hide();

    window.addEventListener('message', function(event){
        var eventData = event.data;
        console.log(eventData.action)

        if (eventData.action == "cwCrafting") {
            if (eventData.toggle) {
                cwCrafting.Open()
            }
        }
    });
});

function handleConfirm() {
    console.log('confirmed', currentAd.title)
    if(currentAd){
        $.post('https://cw-darkweb/confirmPurchase', JSON.stringify(currentAd), function(wentThrough){
            console.log('aaa', wentThrough)

            if (wentThrough) {
                console.log(currentAd.name)
                $.post('https://cw-darkweb/removeAd', JSON.stringify(currentAd.name));
                $(".confirmation-box").hide('')
                $(`#${currentAd.name}${currentAdId}`).hide('')
            }
        });
    }
}

function handleCraft() {
    console.log('current recipie', JSON.stringify(currentRecipie))
    $.post('https://cw-crafting/attemptCrafting', JSON.stringify(currentRecipie), function(success){
        if (success) {
            console.log('successfully crafted an item')
        }
    })
}

function handleClickRecipie(recipieName) {
    console.log('click', JSON.stringify(recipieName))
    if(recipieName) {
        currentRecipie = recipieName;
        $(".recipie-confirmation-container").show();
        let recipie = Recipies[recipieName];
        console.log('recipie ', JSON.stringify(recipie))
        $("#title").html(recipie.data.label)
        $(".recipie-info").html('');
        $.each(recipie.materials, function(material, amount){
            console.log(material, amount)
            let row = `
            <div id="${material}-row" class="material-list-row">
                <div class="left"> ${material} </div>
                <div class="right"> ${amount} </div>
            </div>
            `
            $(".recipie-info").append(row);
        })

    } else {
        console.log('something went wrong')
    }

}

let filterByCategory = function(category) {
    console.log('filtering by', category)
    if(Categories === null) {
        return
    } else {
        $(".category-container").hide();
        $(".recipie-container").show();
        $(".recipie-list").html("");

        $.each(Recipies, function(i,recipie) {
            if(recipie.category === category) {
                let amount = recipie.amount? recipie.amount : 1;
                console.log('image', 'recipie.data.image')
                let element = `
                <div id="${recipie.name}${i}" class="card" onclick="handleClickRecipie('${recipie.name}')">
                    <div class="card-icon">
                        <img src="/recipieImages/${recipie.data.image}" />
                    </div>
                    <div class="card-content"> 
                        <div class="card-header">
                            ${recipie.data.label}
                        </div>
                        <div class="chip-list">
                        <div class="chip"> x${amount} </div>
                        <div class="chip"> ${recipie.craftTime/1000}s </div>
                        </div>
                    </div>
                </div>
                `;
            $(".recipie-list").append(element);
            }
        })
    }
}
// qb-inventory/html/images/
//<img src="../../../[qb]/qb-inventory/html/images/${recipie.data.image}"/>

let SetCategories = function () {
    Categories = []
    $.each(Recipies, function(i,recipie) {
        console.log('checking', JSON.stringify(recipie))
        if( Categories.includes(recipie.category) ) {
            console.log(recipie.category, ' already existed')
        } else {
            Categories.push(recipie.category)
        }
    })
}

let LoadCategoryList = function() {
    console.log('Loading categories')
    $(".recipie-container").hide();
    $(".category-container").show();
    $(".category-list").html("");
    $(".recipie-confirmation-container").hide();

    $.each(Categories, function(i, category) {
        let element = `
            <div id="${category}${i}" class="card" onclick="filterByCategory('${category}')">
                <div class="card-header">
                    ${category}
                </div>
            </div>
            `;
        $(".category-list").append(element);
    });
    console.log('Categories', JSON.stringify(Categories))
}

let goBack = function() {
    LoadCategoryList()
}

cwCrafting.Open = function() {
    console.log('opening crafting')
    $.post('https://cw-crafting/getRecipies', function(recipies){
        if (recipies) {
            console.log('recipies', JSON.stringify(recipies))
            Recipies = recipies;
            $('.crafting-container').fadeIn(950);
            SetCategories();
            LoadCategoryList();
        }
    })
}

cwCrafting.Close = function() {
    $('.crafting-container').fadeOut(250);
    $.post('https://cw-crafting/closeCrafting');
}

$(document).on('keydown', function(event) {
    switch(event.keyCode) {
        case 27:
            cwCrafting.Close();
            break;
    }
});