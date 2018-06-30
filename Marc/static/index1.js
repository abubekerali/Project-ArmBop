function init()  {

    getOptions();

}



//Build and Populate the Data Panel

function updateMetaDataPanel(data) {

    //Populate the Meta Data Panel.  Locate element id first.
    var METADATAPANEL = document.getElementById("display_meta_data");
    //Clear out the panel 
    METADATAPANEL.innerHTML = '';
    //Put the data in the h6 headers within the panel
    for(var key in data) {
        h5tag = document.createElement("h5");
        h5Text = document.createTextNode(`${key}: ${data[key]}`);
        h5tag.append(h5Text);
        METADATAPANEL.appendChild(h5tag);
    }
}
//////////////////////////////////////////////////////////////////////////////

//Retrieves the metadata for a sample. Calls the function to update the display 
function getData(sample) {

    Plotly.d3.json(`/metadata/${sample}`, function(error, metaData) {
        if (error) return console.warn(error);
        console.log("The metadata is");
        console.log(metaData);
        updateMetaDataPanel(metaData);
    })

}


function createpieplot(plotdata) {
    console.log("Inside createpieplot")
 ;
}

function createpieplot2(plotdata) {
    console.log("Inside createpieplot1")
 ;
}

function createpieplot3(plotdata) {
    console.log("Inside createpieplot1")
 ;
}
//This function responds to the selection from the selection in the HTML drop-down menu 
//Calls the function to update the data in the metadata frame on the display
//Calls the function to upoate the pie plot.

function optionChanged(new_sample) {
    // Collect new samples when a sample is selected on the drop down menu
    console.log("The new sample is");
    console.log(new_sample)
    getData(new_sample);
//    updateplots(new_sample);

}

//Build the Drop Down List.  Use the list of samples from /names
//The element id in the html is called <select id='selDataset'

function getOptions() {

    var selDataset = document.getElementById('selDataset');

    Plotly.d3.json('/names', function(error, sampleNames) {
        for (var i = 0; i < sampleNames.length;  i++) {
            var currentOption = document.createElement('option');
            currentOption.text = sampleNames[i];
            currentOption.value = sampleNames[i]
            selDataset.appendChild(currentOption);
        }
        //Populate the meta data frame after the page is first loaded
      getData(sampleNames[0]);

      createpieplot(Plotly.d3.json('/continents', function(error, sampleNames) {
        if (error) return console.warn(error);
        console.log("The Continent Flight Data is");
        console.log(sampleNames);
        console.log("The Continent Flight Key Data is");
        console.log(Object.keys(sampleNames));
        console.log("The Continent Flight Value Data is");
        console.log(Object.values(sampleNames))

        var data = [{
            values: Object.values(sampleNames),
            labels: Object.keys(sampleNames),
            type: 'pie'
          }];
          
          Plotly.newPlot('pie', data);

       }) )  
       createpieplot2(Plotly.d3.json('/flights', function(error, sampleNames) {
        if (error) return console.warn(error);
        console.log("The Country Flight Data is");
        console.log(sampleNames);
        console.log("The Continent Flight Key Data is");
        console.log(Object.keys(sampleNames));
        console.log("The Continent Flight Value Data is");
        console.log(Object.values(sampleNames))

        var data = [{
            values: Object.values(sampleNames),
            labels: Object.keys(sampleNames),
            type: 'pie'
          }];
          
          Plotly.newPlot('piecountry', data);

       }) )  
       createpieplot3(Plotly.d3.json('/ownership', function(error, sampleNames) {
        if (error) return console.warn(error);
        console.log("The Country Flight Data is");
        console.log(sampleNames);
        console.log("The Continent Flight Key Data is");
        console.log(Object.keys(sampleNames));
        console.log("The Continent Flight Value Data is");
        console.log(Object.values(sampleNames))

        var data = [{
            values: Object.values(sampleNames),
            labels: Object.keys(sampleNames),
            type: 'pie'
          }];
          
          Plotly.newPlot('pieorigin', data);

       }) )
    })
}


init();