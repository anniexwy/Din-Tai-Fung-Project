# Din-Tai-Fung-Project

### Background & Goals for the Project
Din Tai Fung is restaurant chain headquartered in Taiwan. The restaurant chain has gained international recognition for its exquisite cuisine, particularly its signature dish, Xiaolongbao, which is a type of steamed dumpling. The restaurant began to team up with an online ordering platform during the COVID-19 pedemic so that people can enjoy their meals at home. On April 1st, 2023, they lauched a new feature for the ordering process on the ordering platform. The sales team of the restaurant has approached you on May 18th, 2023 and asked you to do some analysis for their sales performance from the beginning of 2023 to May 17th, 2023.

The files they provided to you include general information of the dishes, orders they recieved on the platform and deatailed order information of each order. The following are the questions they would like you to answer:

* How much money did Din Tai Fung made?
* How many dishes are typically in an order? And which dishes are Din Tai Fung's bestsellers?
* Are there any busy days in a week?
* Are there any changes in the sales of each cuisine, before and after the new feature was launched?

Also, they told you to feel free to exclude the data which may cause bias in your analysis.

### Steps I went through
#### 1. Data cleasing in PostgreSQL
   _(See the .sql file in the repository for detail)_

_While cleaning the data, I noticed the data for the week starting from May 14th (I define Sunday as the beginning of the week) is incomplete. In order to aviod bias, I limit the data to May 13th, 2023._

#### 2. Conducted analysis according to the requests in PostgreSQL
   _(See the .sql file in the repository for detail)_

#### 3. Visualized my findings in Tableau 
* Loaded the merged tables into Tableau
* Created calcualted fields to calculate number of orders, number of dishes sold and dishes sold per order
* Applied date filters to relevant worksheets, ensuring the data are comparable and relevant for my analysis
* Designed interactive dashboards using the graphs I created in the worksheets

(Dashboard Link: https://public.tableau.com/views/DinTaiFungProject/Dashboards?:language=zh-CN&:display_count=n&:origin=viz_share_link)

### Insights & Suggestions

* Up until May 13th, 2023, Din Tai Fung received NT$12M in revenue by selling more than 14K dishes in 3,742 orders.

* The customers often order nearly 4 dishes (3.83 to be precise) for their orders.

* Not surprisingly, Xiaolongbao is the most ordered type of dishes and brings the most revenue among all the other dishes types (NT$1.01M). To be more specific, Pork Xiaolongbao is ordered slightly more times than the other dishes (911 dishes), while Crab Roe and Pork Xiaolongbao brings the most revenue (NT$323k).

* Fridays turn out to be the least busiest days for Din Tai Fung with 510 total orders in this 5-month period.

* As can be seen from the weekly order & revenue trends, after the new feature was lauched, both orders and reveune increased. This indicates that in general, the new feature seems effective in boosting sales & revenue. However, since the new feature has only lauched for more than one month, it is suggested that Din Tai Fung should conduct some further analysis for the long-term effect of this new feature in the future.  

* After the introduction of the new features, Shrimp Fried Rice became Din Tai Fung customers' favourite fried rice, and Vegetarian Mushroom Buns became their new second favourite buns and the new main revenue-driver of the Buns category. But were these changes resulted from the introduction of the new feature, or by other aspects (e.g. quality issue)? It is suggested to take a look at the reviews leave by the customers during this period and conduct further analysis.
   
*Note: The order records in this dataset are not real-world data, but the cuisines and prices are based on real world menu.

_(Data Source: Kaggle)_
