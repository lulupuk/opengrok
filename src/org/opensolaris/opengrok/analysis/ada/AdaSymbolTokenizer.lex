/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * See LICENSE.txt included in this distribution for the specific
 * language governing permissions and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at LICENSE.txt.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */

/*
 * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
 * Portions Copyright (c) 2017, Chris Fraire <cfraire@me.com>.
 */

/*
 * Gets Ada symbols - ignores comments, strings, keywords
 */

package org.opensolaris.opengrok.analysis.ada;

import java.io.IOException;
import org.opensolaris.opengrok.analysis.JFlexTokenizer;
import org.opensolaris.opengrok.web.HtmlConsts;
import org.opensolaris.opengrok.web.Util;

%%
%public
%class AdaSymbolTokenizer
%extends JFlexTokenizer
%implements AdaLexListener
%unicode
%ignorecase
%type boolean
%char
%init{
    super(in);
    h = new AdaLexHelper(this);
%init}
%{
    private final AdaLexHelper h;

    private String lastSymbol;

    public void pushState(int state) { yypush(state); }

    public void popState() throws IOException { yypop(); }

    public void switchState(int state) { yybegin(state); }

    public void take(String value) throws IOException {
        // noop
    }

    public void takeNonword(String value) throws IOException {
        // noop
    }

    public void takeUnicode(String value) throws IOException {
        // noop
    }

    public boolean takeSymbol(String value, int captureOffset,
        boolean ignoreKwd)
            throws IOException {
        if (ignoreKwd || !Consts.kwd.contains(value.toLowerCase())) {
            lastSymbol = value;
            setAttribs(value, yychar + captureOffset, yychar + captureOffset +
                value.length());
            return true;
        } else {
            lastSymbol = null;
        }
        return false;
    }

    public void skipSymbol() {
        lastSymbol = null;
    }

    public void takeKeyword(String value) throws IOException {
        lastSymbol = null;
    }

    public void doStartNewLine() throws IOException {
        // noop
    }

    public void pushback(int numChars) {
        yypushback(numChars);
    }

    protected boolean takeAllContent() {
        return false;
    }

    protected boolean returnOnSymbol() {
        return lastSymbol != null;
    }

    protected boolean getSymbolReturn() {
        return true;
    }

    protected String getUrlPrefix() { return null; }

    protected void appendProject() { /* noop */ }

    protected void appendLink(String s) { /* noop */ }

    protected void writeEMailAddress(String s) { /* noop */ }
%}
%eofval{
this.finalOffset =  zzEndRead;
return false;
%eofval}

%include AdaProductions.lexh