Smartdown Smart Answers
=============

Smartdown flows are stored in `lib/smartdown_flows`.

The code responsible for executing the flow of those questions is in the [smartdown gem](https://github.com/alphagov/smartdown).

##Smartdown scenarios check

A smartdown content test has been created to run through the test scenarios on all Smartdown questions and ensure they still pass.
To run only that test, use the command:

```rake test TEST=test/unit/smartdown_content/smartdown_scenarios_test.rb```

For every smartdown flow, this goes through all the scenarios defined for them and:
- checks each set of questions has been asked in the right order
- checks the right outcome has been reached given the answers

##Pay and leave for parents

Three tools specific to the pay and leave for parents tool were developed to facilitate question writing and fact-checking.

###Outcome generation

```rake smartdown_generate_outcomes:pay_leave_for_parents```

This command goes through all the outcomes listed in the Pay and leave for parents questions and generates outcome files that
are prepopulated with snippets.
For the pay and leave for parents, we use the convention of naming each outcome as an `_`-separated string of all snippets to be listed for that outcome.

###Factcheck table generation

```rake smartdown_generate_factcheck:pay_leave_for_parents```

####Output of the tool

This rake task builds four markdown documents and saves them to the ```smart-answers-factcheck``` project.
Those four markdown documents summarise the question outcomes for:
* Birth cases before 05/04/2015
* Birth cases after 05/04/2015

Each markdown document is a table summarising the answers given to each question and listing what types of maternity,
paternity, adoption, shared parental leave and pay the user(s) is/are eligible for given their answer.

####How possible combinations are generated

We have chosen for each question in the pay and leave for parents a selection of answers that can affect the outcome of the tool.
This is not an exhaustive list of possible answers. As the tool evolves and more legal rules are added, **possible answers
that can affect the outcome of the flow should be added to the combinations to have an accurate and complete factcheck table**.

###Factcheck diff

```rake smartdown_generate_factcheck:diff_pay_leave_for_parents```

####Output of the tool

This rake task builds the factcheck table for the current state of the pay leave for parents smartdown flows
and generates a diff of the factcheck tables currently in the smart-answers-factcheck project. This rake task should be used
to ensure that when modifying the flow, outcomes are not accidentally changed in areas of the flow not meant to be modified.
