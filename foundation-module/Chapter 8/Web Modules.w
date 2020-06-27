[WebModules::] Web Modules.

To search for included modules, and track dependencies between them.

@h Creation.
Each web of source material discovered by Inweb is given one of the following.
Ordinarily these are found only when reading in a web for weaving, tangling
and so on: in the vast majority of Inweb runs, all modules will have the
"module origin marker" |READING_WEB_MOM|. But when Inweb is constructing a
makefile for a suite of tools, it can also discover multiple webs by other
means.

@e READING_WEB_MOM from 0
@e MAKEFILE_TOOL_MOM
@e MAKEFILE_WEB_MOM
@e MAKEFILE_MODULE_MOM

=
typedef struct module {
	struct pathname *module_location;
	struct text_stream *module_name;
	struct linked_list *dependencies; /* of |module|: which other modules does this need? */
	struct text_stream *module_tag;
	int origin_marker; /* one of the |*_MOM| values above */
	struct linked_list *chapters_md; /* of |chapter_md|: just the ones in this module */
	struct linked_list *sections_md; /* of |section_md|: just the ones in this module */
	CLASS_DEFINITION
} module;

@ =
module *WebModules::new(text_stream *name, pathname *at, int m) {
	module *M = CREATE(module);
	M->module_location = at;
	M->module_name = Str::duplicate(name);
	M->dependencies = NEW_LINKED_LIST(module);
	M->origin_marker = m;
	M->module_tag = I"miscellaneous";
	M->chapters_md = NEW_LINKED_LIST(chapter_md);
	M->sections_md = NEW_LINKED_LIST(section_md);
	return M;
}

@ In the Inweb documentation, "module" is used to refer to a sidekick web which
contains a suite of utility routines, or a major component of a program, but
which is not a program in its own right.

Internally, though, every web produces a |module| structure. The one for the
main web -- which can be tangled, and results in an actual program -- is
internally named |"(main)"|, a name which the user will never see.

=
module *WebModules::create_main_module(web_md *WS) {
	return WebModules::new(I"(main)", WS->path_to_web, READING_WEB_MOM);
}

@h Dependencies.
When web A imports module B, we will say that A is dependent on B. A web
can import multiple modules, so there can a list of dependencies. These are
needed when constructing makefiles, since the source code in B affects the
program generated by A.

=
void WebModules::dependency(module *A, module *B) {
	if ((A == NULL) || (B == NULL)) internal_error("no module");
	ADD_TO_LINKED_LIST(B, module, A->dependencies);
}

@h Searching.
The following abstracts the idea of a place where modules might be found.
(At one time there was going to be a more elaborate search hierarchy.)

=
typedef struct module_search {
	struct pathname *path_to_search;
	CLASS_DEFINITION
} module_search;

@ =
module_search *WebModules::make_search_path(pathname *ext_path) {
	module_search *ms = CREATE(module_search);
	ms->path_to_search = ext_path;
	return ms;
}

@ When a web's contents page says to |import Blah|, how do we find the module
called |Blah| on disc? We try four possibilities in sequence:

=
module *WebModules::find(web_md *WS, module_search *ms, text_stream *name, pathname *X) {
	TEMPORARY_TEXT(T)
	WRITE_TO(T, "%S-module", name);
	pathname *tries[4];
	tries[0] = WS?(WS->path_to_web):NULL;
	tries[1] = tries[0]?(Pathnames::up(tries[0])):NULL;
	tries[2] = X;
	tries[3] = ms->path_to_search;
	int N = 4;
	for (int i=0; i<N; i++) {
		pathname *P = Pathnames::from_text_relative(tries[i], T);
		if ((P) && (WebModules::exists(P))) @<Accept this directory as the module@>;
	}
	DISCARD_TEXT(T)
	return NULL;
}

@ When the module is found (if it is), a suitable module structure is made,
and a dependency created from the web's |(main)| module to this one.

@<Accept this directory as the module@> =
	pathname *Q = Pathnames::from_text(name);
	module *M = WebModules::new(Pathnames::directory_name(Q), P, READING_WEB_MOM);
	WebModules::dependency(WS->as_module, M);
	return M;

@ We accept that a plausibly-named directory is indeed the module being
sought if it looks like a web.

=
int WebModules::exists(pathname *P) {
	return WebMetadata::directory_looks_like_a_web(P);
}

@h Resolving cross-reference names.
Suppose we are in module |from_M| and want to understand which section of
a relevant web |text| might refer to. It could be the name of a module,
either this one or one dependent on it; or the name of a chapter in one
of those, or the shortened forms of those; or the name of a section. It
may match multiple possibilities: we return how many, and if this is
positive, we write the module in which the first find was made in |*return M|,
the section in |*return_Sm|, and set the flag |*named_as_module| according
to whether the reference was a bare module name (say, "foundation") or not.

Note that we consider first the possibilities within |from_M|: we only
look at other modules if there are none. Thus, an unambiguous result in
|from_M| is good enough, even if there are other possibilities elsewhere.

A reference in the form |module: reference| is taken to be in the module
of that name: for example, |"foundation: Web Modules"| would find the
section of code you are now reading.

=
int WebModules::named_reference(module **return_M, section_md **return_Sm,
	int *named_as_module, text_stream *title, module *from_M, text_stream *text, int list) {
	*return_M = NULL; *return_Sm = NULL; *named_as_module = FALSE;
	module *M;
	int finds = 0;
	if (from_M == NULL) return 0;
	match_results mr = Regexp::create_mr();
	text_stream *seek = text;
	if (Regexp::match(&mr, text, L"(%C+?): *(%c+?) *")) {
		LOOP_OVER_LINKED_LIST(M, module, from_M->dependencies)
			if (Str::eq_insensitive(M->module_name, mr.exp[0])) {
				seek = mr.exp[1];
				@<Look for references to chapters or sections in M@>;
			}
	}
	Regexp::dispose_of(&mr);
	seek = text;
	for (int stage = 1; ((finds == 0) && (stage <= 2)); stage++) {
		if (stage == 1) {
			M = from_M;
			@<Look for references to chapters or sections in M@>;
		}
		if (stage == 2) {
			LOOP_OVER_LINKED_LIST(M, module, from_M->dependencies)
				@<Look for references to chapters or sections in M@>;
		}
	}
	return finds;
}

@<Look for references to chapters or sections in M@> =
	if (M == NULL) internal_error("no module");
	if (Str::eq_insensitive(M->module_name, seek))
		@<Found first section in module@>;
	chapter_md *Cm;
	section_md *Sm;
	LOOP_OVER_LINKED_LIST(Cm, chapter_md, M->chapters_md) {
		if ((Str::eq_insensitive(Cm->ch_title, seek)) ||
			(Str::eq_insensitive(Cm->ch_basic_title, seek)) ||
			(Str::eq_insensitive(Cm->ch_decorated_title, seek)))
			@<Found first section in chapter@>;
		LOOP_OVER_LINKED_LIST(Sm, section_md, Cm->sections_md)
			if (Str::eq_insensitive(Sm->sect_title, seek))
				@<Found section by name@>;
	}

@<Found first section in module@> =
	finds++;
	if (finds == 1) {
		*return_M = M; *return_Sm = FIRST_IN_LINKED_LIST(section_md, M->sections_md);
		*named_as_module = TRUE;
		WRITE_TO(title, "the %S module", M->module_name);
	}
	if (list) WRITE_TO(STDERR, "(%d)  Module '%S'\n", finds, M->module_name);

@<Found first section in chapter@> =
	finds++;
	if (finds == 1) {
		*return_M = M; *return_Sm = FIRST_IN_LINKED_LIST(section_md, Cm->sections_md);
		WRITE_TO(title, "%S", Cm->ch_title);
	}
	if (list) WRITE_TO(STDERR, "(%d)  Chapter '%S'\n", finds, Cm->ch_title);

@<Found section by name@> =
	finds++;
	if (finds == 1) {
		*return_M = M; *return_Sm = Sm;
		WRITE_TO(title, "%S", Sm->sect_title);
	}
	if (list) WRITE_TO(STDERR, "(%d)  Section '%S'\n", finds, Sm->sect_title);
