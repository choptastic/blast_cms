-module(blast_common).
-include("base.hrl").

parent_app() ->
    {ok, App} = application:get_application(nitrogen_main_handler),
    App.

priv_dir() ->
    code:priv_dir(parent_app()).

content_dir() ->
    filename:join([priv_dir(), "static", "content"]).

content_dir(Page) ->
    filename:join([content_dir(), wf:to_list(Page)]).

content_dir_url() ->
    "/content/".

content_dir_url(Page) ->
    content_dir_url() ++ Page ++ "/".

config_path(Page) ->
    File = "page.config",
    filename:join([content_dir(Page), File]).

site_config_path() ->
    File = "site.config",
    filename:join([content_dir(), File]).

content_path(Page, Content) ->
    File = wf:to_list(Content) ++ ".md",
    filename:join([content_dir(Page), File]).

content_image_url(Page, Content) ->
    Wildcard = wf:to_list(Content) ++ ".{png,jpg,jpeg,gif,webp}",
    Cwd = content_dir(Page),
    case filelib:wildcard(Wildcard, Cwd) of
        [] -> undefined;
        [File|_] -> content_dir_url(Page) ++ File
    end.

orientation() ->
    Left = case erlang:get(page_orientation_left) of
        undefined -> true;
        true -> true;
        false -> false
    end,
    NewLeft = not(Left),
    erlang:put(page_orientation_left, NewLeft),
    ?WF_IF(Left, left, right).

get_counter(Min, Max) ->
    Counter = case erlang:get(page_counter) of
        undefined -> Min;
        X when X == Max -> Max;
        X when X > Max -> Min;
        X when X < Min -> Min;
        X -> X
    end,
    NextCounter = Counter+1,
    erlang:put(page_counter, NextCounter),
    Counter.

page() ->
    (wf:page_module()):page().

contact_details() ->
    File = filename:join([content_dir(page()), "contact_details.md"]),
    #template{file=File, from_type=gfm, to_type=html}.

site_config() ->
    wf:cache(blast_site_config, 1000, fun() ->
        ConfigPath = site_config_path(),
        {ok, [Config]} = file:consult(ConfigPath),
        Config
    end).

page_config(Page) ->
    wf:cache({blast_page_config, Page}, 1000, fun() ->
        ConfigPath = config_path(Page),
        {ok, [Config]} = file:consult(ConfigPath),
        Config
    end).

page_config(Page, Key) ->
    page_config(Page, Key, []).

page_config(Page, Key, Default) ->
    Config = page_config(Page),
    ds:get(Config, Key, Default).

site_config(Key) ->
    site_config(Key, []).

site_config(Key, Default) ->
    Config = site_config(),
    ds:get(Config, Key, Default).

sections(Page) ->
    page_config(Page, sections, []).

title(Page) ->
    page_config(Page, title).

logo(Page) ->
    case page_config(Page, logo, undefined) of
        undefined ->
            site_config(logo, undefined);
        Logo ->
            Logo
    end.

page_menu_items(Page) ->
    page_config(Page, menu, undefined).

site_menu_items() ->
    site_config(menu, undefined).

site_title() ->
    site_config(title, undefined).

site_logo() ->
    site_config(logo, undefined).

menu_items(Page) ->
    case page_menu_items(Page) of
        undefined ->
            case site_menu_items() of
                undefined -> [];
                X -> X
            end;
        X ->
            X
    end.

has_menu_items(Page) ->
    case menu_items(Page) of
        X when is_list(X), length(X) > 0 ->
            true;
        _ ->
            false
    end.

menu_hamburger() ->
    <<"
        <a role=\"button\" class=\"navbar-burger\" aria-label=\"menu\" aria-expanded=\"false\" data-target=\"navbarMenu\">
           <span aria-hidden=\"true\"></span>
           <span aria-hidden=\"true\"></span>
           <span aria-hidden=\"true\"></span>
        </a>
    ">>.

