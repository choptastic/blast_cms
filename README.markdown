# Blast CMS

A simple Nitrogen-based site generator for quickly building simple sites

## TODO

- Make an install script that does all of the below automatically
- Add support for drop-down submenus
- Add support for callouts to module functions in the `sections`, for example:
  `{callout, {module, function, Args}}`
- Add support for JSON-style configuration (for those who might not want to use
  Erlang)

## Step 0: Create a Nitrogen App

Start with a [Nitrogen](https://nitrogenproject.com) App.

## Step 1: Add dependency

Add it to the dependencies of a Nitrogen application.

Edit your rebar config to add

```erlang
{deps, [
  blast_cms
]}.
```

## Step 2: Update configuration

Set up configuration to have your 404 pages be handled by `blast_basic`:

Edit the `etc/app.config` file and add the following under the `nitrogen_core` key:

```erlang
{file_not_found_module, blast_basic}
```

## Step 3: Add your site configuration

- site.config
- Site name
- Default Logo
- Main Menu items

## Step 4: Add pages

- Create directory
- Add page.config
- define sections
