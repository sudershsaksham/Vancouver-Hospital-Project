# Vancouver Hospital Project

The Vancouver Emergency Room Wait Times Research Project was undertaken to answer two questions:

1. Are Healthcare Resources (specifically, ER) allocated efficiently?
2. Can patients self-allocate to ER to save time and lower staff requirements? If so, how much time is saved?

This repository includes R Codes and Example Data to help scrape ER wait times across Vancouver, as well as analyse and approximate wait time reduction if the system was made efficient. This approximation is rudimentary and only serves to help understand the massive costs to inefficient self-distribution of patients. 

### Logic

*Emergency Rooms in Vancouver are often overwhelmed with 3-4 hour wait times. On the part of ERs, the first time the patient comes in, they screen for medical needs and requirements of the patient, and place the patient in a queue based on severity. For this reason, it is recommended to go to the nearest ER always. Only for patients who don't need immediate medical attention is it an option to choose an ER based on wait times. 
Nevertheless, as a simplified model where all patients are suffering from something relatively benign, this research can point out important inefficiencies and the magnitude of the cost of this inefficiency. It can also help define further actions that need to be taken, such as finding which ERs require more staffing.*

For any patient that seeks ER services, there are 2 times that require waiting before they get the needed attention. They first need to travel to an ER and then wait at the ER after an initial medical checkup.
In some cases, especially with increasing wait times at particular ERs, it can be helpful for some patients to travel to one that is not the closest, but one that has lesser patients. 

- To scrape the data, A selenium wrapper for R (RSelenium) is used, since the page is non-static. This makes data collection more resource-intensive as compared to gathering from a static source. 
- All data collected on wait times is stored in the `temp` dataframe in the `maps_api_test.R` file.
- Google Matrix API is used to find travel times from all ERs to all other ERs, stored as `final` in the `maps_api_test.R` file. This, combined with the wait times at each ER, allows us to see which 'transfers' (travel from one ER to the other) would be 'efficient' (would save time).

### Further Research and Applications

- By collecting data from a longer time period, this research can suggest which ERs require more staffing and help. It can also be expanded to suggest where the next ER should be established as the city continues to grow.
- Moreover, a website that suggested which ER to go to given a location could help both patients as well as staff, by reducing wait times and loads.