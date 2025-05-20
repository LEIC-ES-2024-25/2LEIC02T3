# _FEUP-COINS_ Development Report

Welcome to the documentation pages of _FEUP-COINS_!

This Software Development Report, tailored for LEIC-ES-2024-25, provides comprehensive details about _FEUP-COINS_, from high-level vision to low-level implementation decisions. It’s organised by the following activities.

* [Business modeling](#Business-Modelling)
  * [Product Vision](#Product-Vision)
  * [Features and Assumptions](#Features-and-Assumptions)
  * [Elevator Pitch](#Elevator-pitch)
* [Requirements](#Requirements)
  * [User stories](#User-stories)
  * [Domain model](#Domain-model)
* [Architecture and Design](#Architecture-And-Design)
  * [Logical architecture](#Logical-Architecture)
  * [Physical architecture](#Physical-Architecture)
  * [Vertical prototype](#Vertical-Prototype)
* [Project management](#Project-Management)
  * [Sprint 0](#Sprint-0)
  * [Sprint 1](#Sprint-1)
  * [Sprint 2](#Sprint-2)
  * [Sprint 3](#Sprint-3)
  * [Sprint 4](#Sprint-4)
  * [Final Release](#Final-Release)

Contributions are expected to be made exclusively by the initial team, but we may open them to the community, after the course, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us!

Thank you!

# 2LEIC02T3

## Projeto realizado por:

* Carlos Cristelo up202307628
* Francisco Antunes up202307639
* João Quental up202307755
* Luís Ferreira up202007664

---
## Business Modelling

Business modeling in software development involves defining the product's vision, understanding market needs, aligning features with user expectations, and setting the groundwork for strategic planning and execution.

### Product Vision

Our app empowers users to adopt eco-friendly habits through engaging challenges and rewarding achievements. By tracking steps, encourage to limit shower and screen time, to take public transports, to walk and/or ride a bike instead of using a car and promoting the exchange of study materials, we encourage sustainable behaviors while fostering a sense of community.

For: Environmentally conscious individuals and students

Who: Want to track their eco-friendly activities and feel motivated to do these more and more often

The app: Provides a platform to earn points, unlock badges,, and enable users to exchange study materials

Unlike: Other fitness or trading apps, our solution uniquely combines sustainability challenges with gamification to promote long-term engagement and positive environmental impact, while presenting a very smart and intuitive way to encourage users to adopt sustainable behaviours.

<!-- 
Start by defining a clear and concise vision for your app, to help members of the team, contributors, and users into focusing their often disparate views into a concise, visual, and short textual form. 

The vision should provide a "high concept" of the product for marketers, developers, and managers.

A product vision describes the essential of the product and sets the direction to where a product is headed, and what the product will deliver in the future. 

**We favor a catchy and concise statement, ideally one sentence.**

We suggest you use the product vision template described in the following link:
* [How To Create A Convincing Product Vision To Guide Your Team, by uxstudioteam.com](https://uxstudioteam.com/ux-blog/product-vision/)

To learn more about how to write a good product vision, please see:
* [Vision, by scrumbook.org](http://scrumbook.org/value-stream/vision.html)
* [Product Management: Product Vision, by ProductPlan](https://www.productplan.com/glossary/product-vision/)
* [How to write a vision, by dummies.com](https://www.dummies.com/business/marketing/branding/how-to-write-vision-and-mission-statements-for-your-brand/)
* [20 Inspiring Vision Statement Examples (2019 Updated), by lifehack.org](https://www.lifehack.org/articles/work/20-sample-vision-statement-for-the-new-startup.html)
-->


### Features and Assumptions

#### Initial/Tentative List of High-Level Features

- **Eco-Challenges & Point System** – Users complete challenges (e.g., walking, limit shower time, limit screen time) to earn points.
- **Step Tracking** – Integration with device pedometer to measure steps and convert them into points.
- **Check If Rode Bike and/or Drove Car** - Integration with device activity recognition pluggin.
- **QR Code scanning & generating** - Integration with camera + QR Code pluggin.
- **Screen Time Tracking** - Integration with device screen activity pluggin.
- **Item Trading System** – Users can list, request, and exchange study materials and electronic items.
- **Badges & Achievements** – Unlockable rewards for milestones to boost motivation.

<!-- 
Indicate an  initial/tentative list of high-level features - high-level capabilities or desired services of the system that are necessary to deliver benefits to the users.
 - Feature XPTO - a few words to briefly describe the feature
 - Feature ABCD - ...
...

Optionally, indicate an initial/tentative list of assumptions that you are doing about the app and dependencies of the app to other systems.
-->

### Elevator Pitch
<!-- 
Draft a small text to help you quickly introduce and describe your product in a short time (lift travel time ~90 seconds) and a few words (~800 characters), a technique usually known as elevator pitch.

Take a look at the following links to learn some techniques:
* [Crafting an Elevator Pitch](https://www.mindtools.com/pages/article/elevator-pitch.htm)
* [The Best Elevator Pitch Examples, Templates, and Tactics - A Guide to Writing an Unforgettable Elevator Speech, by strategypeak.com](https://strategypeak.com/elevator-pitch-examples/)
* [Top 7 Killer Elevator Pitch Examples, by toggl.com](https://blog.toggl.com/elevator-pitch-examples/)
-->

## Requirements

### User Stories

- As a user, I want to complete eco-friendly challenges so that I can contribute to a sustainable environment.   XXL

- As a user, I want to trade study materials so that I can reduce waste and promote the reuse of resources.   XXL

- As a user, I want to earn points by completing challenges & earn badges so that I feel motivated to complete more challenges.   L

<!-- - As a user, I want a friend leaderboard so that I can compete in a fun and eco-friendly way. -->

- As a user, I want to generate QR Codes for the eco-friendly events I organize, so the other users who join it can scan it and earn points.   M

- As a user, I want to be notified so that I stay updated and motivated to participate in eco-friendly activities.   M

- As a user, I want to invite my friends so that I can encourage more people to participate in sustainable challenges.   S

- As a user, I want to create and access a personal account through a login process. XL
  
**User Interface Mockups:**

Figma Design: https://www.figma.com/design/ezcvtAeSm4rhMbg6pXw0XD/es_app?node-id=0-1&t=yXBQLDWbp9WCTYYV-1

Figma Prototype: https://www.figma.com/proto/ezcvtAeSm4rhMbg6pXw0XD/es_app?node-id=4-12247&p=f&t=zRR4YlXjMTRbgPGt-1&scaling=scale-down&content-scaling=fixed&page-id=0%3A1&starting-point-node-id=4%3A12247&show-proto-sidebar=1


## Acceptance tests

### Feature: Earn Points by Completing Challenges

#### Scenario: User completes an eco-friendly challenge and earns points

```gherkin
Given the user is using the app
And the user has an active eco-friendly challenge (e.g., "Walk 5000 steps")
When the user completes the challenge
Then the user's point balance should increase by the points assigned to the challenge
And a notification should appear (e.g., "Challenge completed: Walk 5000 steps (+20 points)")
```

### Feature: Earn Badges by Completing Milestones

#### Scenario: User earns a badge for completing a milestone
```gherkin
Given the user is using the app
And the user has completed a milestone (e.g., "Eco Beginner Complete your first eco challenge")
When the system detects the milestone completion
Then the user should receive a badge associated with the milestone and the point balance should increase by the points assigned to the badge
And a notification should appear (e.g., "Badge unlocked: Eco Beginner (+10 points) ")
```

<!-- 
In this section, you should describe all kinds of requirements for your module: functional and non-functional requirements.

For LEIC-ES-2024-25, the requirements will be gathered and documented as user stories. 

Please add in this section a concise summary of all the user stories.

**User stories as GitHub Project Items**
The user stories themselves should be created and described as items in your GitHub Project with the label "user story". 

A user story is a description of a desired functionality told from the perspective of the user or customer. A starting template for the description of a user story is *As a < user role >, I want < goal > so that < reason >.*

Name the item with either the full user story or a shorter name. In the “comments” field, add relevant notes, mockup images, and acceptance test scenarios, linking to the acceptance test in Gherkin when available, and finally estimate value and effort.

**INVEST in good user stories**. 
You may add more details after, but the shorter and complete, the better. In order to decide if the user story is good, please follow the [INVEST guidelines](https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/).

**User interface mockups**.
After the user story text, you should add a draft of the corresponding user interfaces, a simple mockup or draft, if applicable.

**Acceptance tests**.
For each user story you should write also the acceptance tests (textually in [Gherkin](https://cucumber.io/docs/gherkin/reference/)), i.e., a description of scenarios (situations) that will help to confirm that the system satisfies the requirements addressed by the user story.

**Value and effort**.
At the end, it is good to add a rough indication of the value of the user story to the customers (e.g. [MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) method) and the team should add an estimation of the effort to implement it, for example, using points in a kind-of-a Fibonnacci scale (1,2,3,5,8,13,20,40, no idea).

-->

### Domain model

<!-- 
To better understand the context of the software system, it is useful to have a simple UML class diagram with all and only the key concepts (names, attributes) and relationships involved of the problem domain addressed by your app. 
Also provide a short textual description of each concept (domain class). 

Example:
 <p align="center" justify="center">
  <img src="https://github.com/FEUP-LEIC-ES-2022-23/templates/blob/main/images/DomainModel.png"/>
</p>
-->


## Architecture and Design
<!--
The architecture of a software system encompasses the set of key decisions about its organization. 

A well written architecture document is brief and reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the components of the project and their interrelations. You should describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.
-->


### Logical architecture
<!--
The purpose of this subsection is to document the high-level logical structure of the code (Logical View), using a UML diagram with logical packages, without the worry of allocating to components, processes or machines.

It can be beneficial to present the system in a horizontal decomposition, defining layers and implementation concepts, such as the user interface, business logic and concepts.

Example of _UML package diagram_ showing a _logical view_ of the Eletronic Ticketing System (to be accompanied by a short description of each package):

![LogicalView](https://user-images.githubusercontent.com/9655877/160585416-b1278ad7-18d7-463c-b8c6-afa4f7ac7639.png)
-->


### Physical architecture
<!--
The goal of this subsection is to document the high-level physical structure of the software system (machines, connections, software components installed, and their dependencies) using UML deployment diagrams (Deployment View) or component diagrams (Implementation View), separate or integrated, showing the physical structure of the system.

It should describe also the technologies considered and justify the selections made. Examples of technologies relevant for ESOF are, for example, frameworks for mobile applications (such as Flutter).

Example of _UML deployment diagram_ showing a _deployment view_ of the Eletronic Ticketing System (please notice that, instead of software components, one should represent their physical/executable manifestations for deployment, called artifacts in UML; the diagram should be accompanied by a short description of each node and artifact):

![DeploymentView](https://user-images.githubusercontent.com/9655877/160592491-20e85af9-0758-4e1e-a704-0db1be3ee65d.png)
-->


### Vertical prototype
<!--
To help on validating all the architectural, design and technological decisions made, we usually implement a vertical prototype, a thin vertical slice of the system integrating as much technologies we can.

In this subsection please describe which feature, or part of it, you have implemented, and how, together with a snapshot of the user interface, if applicable.

At this phase, instead of a complete user story, you can simply implement a small part of a feature that demonstrates thay you can use the technology, for example, show a screen with the app credits (name and authors).
-->

## Project management
<!--
Software project management is the art and science of planning and leading software projects, in which software projects are planned, implemented, monitored and controlled.

In the context of ESOF, we recommend each team to adopt a set of project management practices and tools capable of registering tasks, assigning tasks to team members, adding estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Common practices of managing agile software development with Scrum are: backlog management, release management, estimation, Sprint planning, Sprint development, acceptance tests, and Sprint retrospectives.

You can find below information and references related with the project management: 

* Backlog management: Product backlog and Sprint backlog in a [Github Projects board](https://github.com/orgs/FEUP-LEIC-ES-2023-24/projects/64);
* Release management: [v0](#), v1, v2, v3, ...;
* Sprint planning and retrospectives: 
  * plans: screenshots of Github Projects board at begin and end of each Sprint;
  * retrospectives: meeting notes in a document in the repository, addressing the following questions:
    * Did well: things we did well and should continue;
    * Do differently: things we should do differently and how;
    * Puzzles: things we don’t know yet if they are right or wrong… 
    * list of a few improvements to implement next Sprint;

-->
**Start:**
![Screenshot from 2025-03-24 23-56-38](https://github.com/user-attachments/assets/c05f2625-4c02-4990-8a6b-d901457af861)


### Sprint 0
**Before:**
![Screenshot from 2025-03-24 23-57-36](https://github.com/user-attachments/assets/b6869127-dac7-46b3-af50-9eed03e196b0)

**After:**
![Screenshot from 2025-03-25 00-00-22](https://github.com/user-attachments/assets/3ba5a248-b84e-4eac-8f95-4e4bcc9a7bf6)

**Retrospective:** The plan that the team agreed for sprint 0 has been entirely fullfiled.

### Sprint 1
**Before:**
![Screenshot sprint1_1](https://github.com/user-attachments/assets/830da8dd-1ed5-4ec6-9506-e02ff4c3f370)


**After:**
![Screenshot sprint1_2](https://github.com/user-attachments/assets/e5deb17a-8300-4d60-929c-463dfeedbd19)

**Retrospective:** 

*What went well:*
Correctly implemented earn points and earn badges feature.

*What went wrong:*
Code refractoring is needed.

*What we would change:*
Refactor the codebase to improve readability, maintainability, and adherence to best practices.

**Happiness Meter**

| **Avaliador \ Avaliado** | **Francisco Antunes** | **Carlos Cristelo** | **Luis Ferreira** | **Joao Quental** |
|--------------------------|------------------------|----------------------|-------------------|------------------|
| **Francisco Antunes**    |           😊           |         ⭐           |        😊          |       ⭐          |
| **Carlos Cristelo**      |          ⭐              |          😊           |        ⭐           |      😊           |
| **Luis Ferreira**        |            😊             |         ⭐              |          😊       |             ⭐      |
| **Joao Quental**         |           ⭐             |           😊          |         ⭐          |         😊         |


⭐ Excellent
😊 Good
😒 Fair
🤔 No idea

## Demo Video

Here's a quick demo of the project:

You can download the demo video [here](assets/demos/Demo_sprint1.mp4).

### Sprint 2
**Before:**
![Screenshot from 2025-04-27 20-15-09](https://github.com/user-attachments/assets/24b892d5-5c31-4919-acca-62185f0c1279)



**After:**
![Screenshot from 2025-04-27 20-16-00](https://github.com/user-attachments/assets/b63d5b0f-7df0-4a6c-a1d2-757aa3771756)


**Retrospective:** 

*What went well:*
Correctly implemented firebase authentication, notifications handler and we also made some changes to the code structure in order to improve readability, maintainability and simplicity.

*What went wrong:*
Many Plugins/APIs we wanted to use had impeding bugs and/or were outdated - we had to find alternatives or try to achieve things in a different way, so it led to a not so good work efficiency because we lost a big amount of time just trying out Plugins/APIs that turned out to be problematic.

*What we would change:*
Nothing.

**Happiness Meter**

| **Avaliador \ Avaliado** | **Francisco Antunes** | **Carlos Cristelo** | **Luis Ferreira** | **Joao Quental** |
|--------------------------|------------------------|----------------------|-------------------|------------------|
| **Francisco Antunes**    |           😊           |          ⭐           |        ⭐          |       ⭐          |
| **Carlos Cristelo**      |          😊              |          😊           |        ⭐           |      😊           |
| **Luis Ferreira**        |            ⭐             |         😊              |          😊       |             ⭐      |
| **Joao Quental**         |           😊             |           😊          |         ⭐          |         😊         |


⭐ Excellent
😊 Good
😒 Fair
🤔 No idea

## Demo Video

Here's a quick demo of the project:

You can download the demo video [here](assets/demos/demo_sprint2.mp4).

**Video Description**

0:00-0:20 : Register and Login pages;

0:21-0:40 : Notifications inside the app;

0:41-0:49 : Notifications outside the app;

0:50-0:54 : Log Out;

0:55-1:12 : Example of misspelled Log In credentials;

1:13-1:19 : Another login in with the same credentials -> same app data.

**Next Sprint Planning**
- Invite people to the app via link.
- Add the trade study materials shop feature.

### Sprint 3

## Demo Video:
You can download the demo video:

[here](assets/demos/demo_sprint3_trade_items.mp4) -- Trade Items.

[here](assets/demos/demo_sprint3_invite_friends.mp4) -- Invite Friends.


### Sprint 4

### Final Release

