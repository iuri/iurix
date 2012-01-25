-- create layout manager themes datamodel
--
-- @author Don Baccus (dhogaza@pacifier.com)
-- @creation-date 2008-07-05
-- @version $Id: themes-create.sql,v 1.1.1.1 2008/07/22 07:31:03 donb Exp $

create table layout_themes (
    name                            text
                                    constraint layout_themes_pk
                                    primary key,
    description                     text,
    template                        text
);

comment on table layout_themes is '
    decoration templates for layout elements
';

comment on column layout_themes.template is '
    The path relative to the lib directory to the theme template

    Example: "themes/deco-theme"
';
