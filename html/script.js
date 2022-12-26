let cwCrafting = {}
let Recipies = []
let Categories = []
let currentRecipie = {}
let currentAdId = -1
let craftingAmount = 1

let inv = 'qb'


$(document).ready(function(){
    /* console.log('lol crafting') */
    $('.crafting-container').hide();
    $.post('https://cw-crafting/getInventory', function(inventory){
        if (inventory) {
            console.log('cw-crafting: Setting inv to', inventory)
            inv = inventory
        }
    })
    window.addEventListener('message', function(event){
        var eventData = event.data;

        if (eventData.action == "cwCrafting") {
            if (eventData.toggle) {
                cwCrafting.Open()
            }
        }
    });
});

function handleCraft() {
    console.log('current recipie', JSON.stringify(currentRecipie), craftingAmount)
    $.post('https://cw-crafting/attemptCrafting', JSON.stringify({currentRecipie, craftingAmount}), function(success){
        if (success) {
            console.log('successfully crafted an item')
        }
    })
}


let handleUpdateAmount = function(selected) {
    craftingAmount = selected.value
    console.log('craft amunt', craftingAmount, currentRecipie)
    handleClickRecipie(currentRecipie)
}

function handleClickRecipie(recipieName) {
    /* console.log('click', JSON.stringify(recipieName)) */
    if(recipieName) {
        currentRecipie = recipieName;
        $(".recipie-confirmation-container").show();
        $(".recipie-info").html('');
        $(".confirmation-subtitle").html('');
        let recipie = Recipies[recipieName];
        let resultAmount = recipie.amount? recipie.amount : 1;
        let hasBlueprint = recipie.blueprint? true: false;
        let hasJob = recipie.jobs ? true: false;
        $("#title").html(recipie.data.label)

        let imageLink = '';
        if ( inv == 'qb' ) {
            imageLink = `nui://qb-inventory/html/images/${recipie.data.image}`
        } else {
            imageLink= `nui://ox_inventory/web/images/${recipie.name}.png`
        }
        $(".header-icon").html(`<div class="card-icon"><img src=${imageLink} class="card-img"/></div>`)
        $(".confirmation-subtitle").append(`<div class="chip"> Amount: ${resultAmount*craftingAmount} </div>`)
        $(".confirmation-subtitle").append(`<div class="chip"> Crafting Time: ${(craftingAmount*recipie.craftTime)/1000}s </div>`)
        if(hasBlueprint) $(".confirmation-subtitle").append(`<div class="chip"> Blueprint </div>`)
        if(hasJob) $(".confirmation-subtitle").append(`<div class="chip"> Job </div>`)

        $.each(recipie.materials, function(material, amount){
            let row = `
            <div id="${material}-row" class="material-list-row">
                <div class="left"> ${material} </div>
                <div class="right"> ${amount*craftingAmount} </div>
            </div>
            `
            $(".recipie-info").append(row);
        })

    } else {
        console.log('something went wrong')
    }

}

let filterByCategory = function(category) {
/*     console.log('filtering by', category) */
    if(Categories === null) {
        return
    } else {
        $(".category-container").hide();
        $(".recipie-container").show();
        $(".recipie-list").html("");
        $.each(Recipies, function(i, recipie) {
            if(recipie.category === category) {
                let amount = recipie.amount? recipie.amount : 1;
                console.log(JSON.stringify(i))
                let imageLink = ''
                if ( inv == 'qb' ) {
                    imageLink = `nui://qb-inventory/html/images/${recipie.data.image}`
                } else {
                    imageLink= `nui://ox_inventory/web/images/${recipie.name}.png`
                }
                let element = `
                <div id="${i.label}" class="card" onclick="handleClickRecipie('${i}')">
                    <div class="card-icon">
                        <img src=${imageLink} class="card-img"/>
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
        /* console.log('checking', JSON.stringify(recipie)) */
        if( Categories.includes(recipie.category) ) {
            /* console.log(recipie.category, ' already existed') */
        } else {
            Categories.push(recipie.category)
        }
    })
}

let LoadCategoryList = function() {
    /* console.log('Loading categories') */
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
    /* console.log('Categories', JSON.stringify(Categories)) */
}

let goBack = function() {
    LoadCategoryList()
}

cwCrafting.Open = function() {
    /* console.log('opening crafting') */
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

$(document).click(function(event) { 
    var $target = $(event.target);
    if(!$target.closest('.app-container').length && 
    $('.app-container').is(":visible")) {
      cwCrafting.Close()
    }        
  });