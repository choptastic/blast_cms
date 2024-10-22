%% vim: ft=nitrogen
%% Copyright 2023-2024 Jesse Gumm
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


draw_section(Page, Section) when is_atom(Section) ->
    draw_section(Page, {Section, Section});
draw_section(Page, Section) when is_map(Section) ->
    ID = ds:get(Section, id),
    draw_section(Page, {ID, Section});
draw_section(Page, {Sectionid, Section})  ->
    #section{
        html_id=Sectionid,
        class=[section, section_classes()],
        body=[
            #panel{class=container, body=[
                content(Page, Section)
            ]}
        ]
    }.
    
content(Page, Section) when is_atom(Section) ->
    File = blast_common:content_path(Page, Section),
    {HasPic, Picture} = case blast_common:content_image_url(Page, Section) of
        undefined -> {false, ""};
        Url -> {true, #image{image=Url}}
    end,

    Orientation = ?WF_IF(HasPic, blast_common:orientation(), full),

    OrientationClass = wf:to_binary(["orientation-",Orientation]),
    
    Text = #template{file=File, from_type=gfm, to_type=html},
    
    BaseClass0 = [column, 'home-details'],

    case Orientation of
        full ->
            BaseClass = [BaseClass0, 'is-full'],
            #panel{class=[columns, OrientationClass, "is-vcentered"], body=[
                #panel{class=[BaseClass], body=Text}
            ]};
        _ ->
            BaseClass = [BaseClass0, 'is-half'],

            {Left, Right} = ?WF_IF(Orientation==left, {Picture, Text}, {Text, Picture}),
            HideMobileClass = "is-hidden-touch",
            {LeftHide, RightHide} = ?WF_IF(Orientation==left, {HideMobileClass, ""}, {"", HideMobileClass}),

            #panel{class=[columns, OrientationClass, "is-vcentered"], body=[
                #panel{class=[BaseClass, "is-hidden-desktop"], body=Picture},
                #panel{class=[BaseClass, LeftHide], body=Left},
                #panel{class=[BaseClass, RightHide], body=Right}
            ]}
    end;

content(Page, Columns) when is_list(Columns) ->
    content(Page, #{columns=>Columns});

content(Page, Section) when is_map(Section) ->
    [ID, Columns, Class] = ds:get_list(Section, [id, columns, class]),
    NumColumns = length(Columns),
    BaseClass = [column, 'home-details', ratio_class(NumColumns)],
    #panel{html_id=ID, class=[columns, Class], body=[
        [content_item(Page, BaseClass, C) || C <- Columns]
    ]}.

ratio_class(1) ->
    'is-full';
ratio_class(2) ->
    'is-half';
ratio_class(3) ->
    'is-one-third';
ratio_class(4) ->
    'is-one-quarter';
ratio_class(5) ->
    'is-one-fifth';
ratio_class(6) ->
    'is-2';
ratio_class(_) ->
    'is-1'.

content_item(Page, BaseClass, Column) ->
    #panel{class=BaseClass, body=guess_and_process_content(Page, Column)}.

guess_and_process_content(Page, Column) ->
    case blast_common:content_guess(Page, Column) of
        {markdown, File} ->
            #template{file=File, from_type=gfm, to_type=html};
        {image, File} ->
            #image{image=File};
        undefined ->
            ""
    end.
    


section_classes() ->
    blast_common:section_classes(page()).

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



