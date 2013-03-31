{
  Delphi Yacc & Lex
  Copyright (c) 2013 by Roman Yankovsky <roman@yankovsky.me>
  Based on Delphi Yacc & Lex Version 1.4
  Based on Turbo Pascal Lex and Yacc Version 4.1

  Copyright (c) 1990-92   Albert Graef <ag@muwiinfa.geschichte.uni-mainz.de>
  Copyright (C) 1996      Berend de Boer <berend@pobox.com>
  Copyright (c) 1998      Michael Van Canneyt <Michael.VanCanneyt@fys.kuleuven.ac.be>
  Copyright (c) 2003-2004 Michiel Rook

  ## $Id: lexlib.pas 1697 2005-12-19 16:27:41Z druid $

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}

unit dlib;

interface

type
  TCustomParser = class
  public
    function Parse: integer; virtual; abstract;
  end;

implementation

end.
