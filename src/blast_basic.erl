%% vim: ft=nitrogen
%% Copyright 2023 Jesse Gumm
%% MIT License
-module(blast_basic).
-include("blast.hrl").
-compile(export_all).

page() ->
    case wf:path_info() of
        "/" -> "index";
        Path ->
            case is_alphanumeric(Path) of
                false -> undefined;
                true -> Path
            end
    end.

is_alphanumeric(Str) ->
    case re:run(Str, "[^a-zA-Z0-9]", [{capture, none}]) of
        match -> false;
        nomatch -> true
    end.

main() ->
    case page() of
        undefined -> web_404:main();
        _ -> #template{file=blast_common:template_dir("blast_basic.html")}
    end.

sections() ->
    Page = page(),
    blast_common:sections(Page).

title() ->
    Page = page(),
    blast_common:title(Page).

body() ->
    Page = page(),
    Sections = blast_common:sections(Page),
    [draw_section(Page, Section) || Section <- Sections].

draw_section(Page, Section) ->
    #section{
        html_id=Section,
        class=[section, section_class()],
        body=[
            #panel{class=container, body=[
                content(Page, Section)
            ]}
        ]
    }.
    
content(Page, Section) ->
    Orientation = blast_common:orientation(),
    File = blast_common:content_path(Page, Section),
    Picture = case blast_common:content_image_url(Page, Section) of
        undefined -> "";
        Url -> #image{image=Url}
    end,
    
    Text = #template{file=File, from_type=gfm, to_type=html},

    BaseClass = "column is-half home-details",

    {Left, Right} = ?WF_IF(Orientation==left, {Picture, Text}, {Text, Picture}),
    OrientationClass = "orientation-" ++ wf:to_list(Orientation),
    HideMobileClass = "is-hidden-touch",
    {LeftHide, RightHide} = ?WF_IF(Orientation==left, {HideMobileClass, ""}, {"", HideMobileClass}),

    #panel{class=[columns, "is-vcentered", OrientationClass], body=[
        #panel{class=[BaseClass, "is-hidden-desktop"], body=Picture},
        #panel{class=[BaseClass, LeftHide], body=Left},
        #panel{class=[BaseClass, RightHide], body=Right}
    ]}.



section_class() ->
    Num = blast_common:get_counter(1, 5),
    "section-" ++ wf:to_list(Num).

navbar() ->
    Page = page(),
    Items = blast_common:menu_items(Page),
    #nav{
        class=[navbar, "is-fixed-top"],
        role=navigation,
        aria=[{label, "main navigation"}],
        body=[
            #panel{class=["navbar-brand"], body=[
                #link{
                    class=["navbar-item", "navbar-logo", large],
                    url="#",
                    body=logo()
                },
                ?WF_IF(not(?WF_BLANK(Items)), blast_common:menu_hamburger())
            ]},
            #panel{class=["navbar-menu"], html_id="navbarMenu", body=[
                #panel{class="navbar-end", body=[
                    draw_menu_items(Items)
                ]}
            ]}
        ]
    }.

draw_menu_items(Items) ->
    [draw_menu_item(I) || I <- Items].

draw_menu_item({Body, URL}) ->
    #link{class=["navbar-item"], url=URL, body=Body}.

logo() ->
    Page = page(),
    Title = blast_common:title(Page),
    case blast_common:logo(Page) of
        undefined ->
            wf:html_encode(Title);
        Url -> 
            #image{image=Url, title=Title}
    end.



