# Blast CMS

A simple Nitrogen-based site generator for quickly building simple sites 

## Step 0: Create a Nitrogen App

Start with a [Nitrogen](https://nitrogenproject.com) App.

## Step 1: Add dependency

Add it to the dependencies of a Nitrogen application.

Edit your rebar config to add

{deps, [
	blast_cms
]}.

## Step 2: Update configuration

Set up configuration to have your 404 pages be handled by `blast_basic`:

Edit the `etc/app.config` file and add the following under the `nitrogen_core` key:

```
{file_not_found_module, blast_basic}
```

## Step 3: Add your site configuration

* site.config
* Site name
* Default Logo
* Main Menu items

## Step 4: Add pages

* Create directory
* Add page.config
* define sections

