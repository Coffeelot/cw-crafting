let cwCrafting = {}
let Recipes = []
let Categories = []
let currentRecipe = {}
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
    // console.log('current recipe', JSON.stringify(currentRecipe), craftingAmount)
    $.post('https://cw-crafting/attemptCrafting', JSON.stringify({currentRecipe, craftingAmount}), function(success){
        if (success) {
            console.log('successfully crafted an item')
        }
    })
}


let handleUpdateAmount = function(selected) {
    craftingAmount = selected.value
    // console.log('craft amunt', craftingAmount, currentRecipe)
    handleClickRecipe(currentRecipe)
}

function handleClickRecipe(recipeName) {
    /* console.log('click', JSON.stringify(recipeName)) */
    if(recipeName) {
        currentRecipe = recipeName;
        $(".recipe-confirmation-container").show();
        $(".recipe-info").html('');
        $(".bd-recipe-info").html('');
        $(".confirmation-subtitle").html('');
        let recipe = Recipes[recipeName];
        let resultAmount = recipe.amount? recipe.amount : 1;
        let hasBlueprint = recipe.blueprint? true: false;
        let hasJob = recipe.jobs ? true: false;
        if(recipe.type == 'breakdown') {
            $("#title").html("Breakdown " + recipe.data.label)
        } else {
            $("#title").html(recipe.data.label)
        }
        if(!recipe.craftingTime) {
            recipe.craftingTime = 1000
        }

        let imageLink = '';
        if ( inv == 'qb' ) {
            imageLink = `nui://qb-inventory/html/images/${recipe.data.image}`
        } else {
            imageLink= `nui://ox_inventory/web/images/${recipe.name}.png`
        }
        $(".header-icon").html(`<div class="card-icon"><img src=${imageLink} class="card-img"/></div>`)
        $(".confirmation-subtitle").append(`<div class="chip"> Amount: ${resultAmount*craftingAmount} </div>`)
        $(".confirmation-subtitle").append(`<div class="chip"> Crafting Time: ${(craftingAmount*recipe.craftingTime)/1000}s </div>`)
        if(hasBlueprint) $(".confirmation-subtitle").append(`<div class="chip"> Blueprint </div>`)
        if(hasJob) $(".confirmation-subtitle").append(`<div class="chip"> Job </div>`)
        $("#components-title").html("Components needed:")
        $.each(recipe.materials, function(material, amount){
            let row = `
            <div id="${material}-row" class="material-list-row">
                <div class="left"> ${recipe.materialsNameMap[material]} </div>
                <div class="right"> ${amount*craftingAmount} </div>
            </div>
            `
            $(".recipe-info").append(row);
        })
        if(recipe.type == 'breakdown') {
            $("#bd-components-title").html("Components recieved:")
            $.each(recipe.toMaterials, function(material, amount){
                let row = `
                <div id="${material}-row" class="material-list-row">
                    <div class="left"> ${recipe.toMaterialsNameMap[material]} </div>
                    <div class="right"> ${amount*craftingAmount} </div>
                </div>
                `
                $(".bd-recipe-info").append(row);
            })
        } else {
            $("#bd-components-title").html("")
        }

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
        $(".recipe-container").show();
        $(".recipe-list").html("");
        $.each(Recipes, function(i, recipe) {
            if(recipe.category === category) {
                if(!recipe.craftingTime) {
                    recipe.craftingTime = 1000
                }
                let amount = recipe.amount? recipe.amount : 1;
                // console.log(JSON.stringify(i))
                let imageLink = ''
                if ( inv == 'qb' ) {
                    imageLink = `nui://qb-inventory/html/images/${recipe.data.image}`
                } else {
                    imageLink= `nui://ox_inventory/web/images/${recipe.name}.png`
                }
                let element = `
                <div id="${i.label}" class="card" onclick="handleClickRecipe('${i}')">
                    <div class="card-icon">
                        <img src=${imageLink} class="card-img"/>
                    </div>
                    <div class="card-content">
                        <div class="card-header">
                            ${recipe.type == 'breakdown' ? 'Breakdown ' + recipe.data.label : recipe.data.label}
                        </div>
                        <div class="chip-list">
                            <div class="chip"> x${amount} </div>
                            <div class="chip"> ${recipe.craftingTime/1000}s </div>
                        </div>
                    </div>
                </div>
                `;
                $(".recipe-list").append(element);
            }
        })
    }
}
// qb-inventory/html/images/
//<img src="../../../[qb]/qb-inventory/html/images/${recipe.data.image}"/>

let SetCategories = function () {
    Categories = []
    $.each(Recipes, function(i,recipe) {
        /* console.log('checking', JSON.stringify(recipe)) */
        if( Categories.includes(recipe.category) ) {
            /* console.log(recipe.category, ' already existed') */
        } else {
            Categories.push(recipe.category)
        }
    })
}

let LoadCategoryList = function() {
    /* console.log('Loading categories') */
    $(".recipe-container").hide();
    $(".category-container").show();
    $(".category-list").html("");
    $(".recipe-confirmation-container").hide();

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
    $.post('https://cw-crafting/getRecipes', function(recipes){
        if (recipes) {
            // console.log('recipes', JSON.stringify(recipes))
            Recipes = recipes;
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