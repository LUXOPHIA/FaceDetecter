(*
  // * copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at>
  // *
  // * This file is part of ffm.
  // *
  // * FFmpeg is free software; you can redistribute it and/or
  // * modify it under the terms of the GNU Lesser General Public
  // * License as published by the Free Software Foundation; either
  // * version 2.1 of the License, or (at your option) any later version.
  // *
  // * FFmpeg is distributed in the hope that it will be useful,
  // * but WITHOUT ANY WARRANTY; without even the implied warranty of
  // * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  // * Lesser General Public License for more details.
  // *
  // * You should have received a copy of the GNU Lesser General Public
  // * License along with FFmpeg; if not, write to the Free Software
  // * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)
unit ffm.log;

{$i ffmpeg.inc}

interface

uses
  ffm.opt;

Type

  PVA_LIST = ^VA_LIST;
  VA_LIST = array [0 .. 0] of Pointer;

  TAVClassCategory = (AV_CLASS_CATEGORY_NA = 0, AV_CLASS_CATEGORY_INPUT, AV_CLASS_CATEGORY_OUTPUT,
    AV_CLASS_CATEGORY_MUXER, AV_CLASS_CATEGORY_DEMUXER, AV_CLASS_CATEGORY_ENCODER, AV_CLASS_CATEGORY_DECODER,
    AV_CLASS_CATEGORY_FILTER, AV_CLASS_CATEGORY_BITSTREAM_FILTER, AV_CLASS_CATEGORY_SWSCALER,
    AV_CLASS_CATEGORY_SWRESAMPLER, AV_CLASS_CATEGORY_NB);

  // struct AVOptionRanges;

  (*
    // * Describe the class of an AVClass context structure. That is an
    // * arbitrary struct of which the first field is a pointer to an
    // * AVClass struct (e.g. AVCodecContext, AVFormatContext etc.).
  *)
  pAVClass = ^TAVClass;

  TItem_name = function(ctx: Pointer): PAnsiChar; cdecl;
  TChild_next = procedure(obj: Pointer; prev: Pointer); cdecl;
  TChild_class_next = function(prev: pAVClass): pAVClass; cdecl;
  TGet_category = function(ctx: Pointer): TAVClassCategory; cdecl;
  TQuery_ranges = function(av_ranges: ppAVOptionRanges; obj: Pointer; key: PAnsiChar; flag: Integer): Integer; cdecl;

  TAVClass = record
    (*
      * The name of the class; usually it is the same name as the
      * context structure type to which the AVClass is associated.
    *)
    class_name: PAnsiChar;
    (*
      * A pointer to a function which returns the name of a context
      * instance ctx associated with the class.
    *)
    // const char* (*item_name)(void* ctx);
    item_name: TItem_name;
    (*
      * a pointer to the first option specified in the class if any or NULL
      *
      * @see av_set_default_options()
    *)
    option: pAVOption;
    (*
      * LIBAVUTIL_VERSION with which this structure was created.
      * This is used to allow fields to be added without requiring major
      * version bumps everywhere.
    *)
    version: Integer;
    (*
      * Offset in the structure where log_level_offset is stored.
      * 0 means there is no such variable
    *)
    log_level_offset_offset: Integer;
    (*
      * Offset in the structure where a pointer to the parent context for
      * logging is stored. For example a decoder could pass its AVCodecContext
      * to eval as such a parent context, which an av_log() implementation
      * could then leverage to display the parent context.
      * The offset can be NULL.
    *)
    parent_log_context_offset: Integer;
    (*
      * Return next AVOptions-enabled child or NULL
    *)
    // void* (*child_next)(void *obj, void *prev);
    child_next: TChild_next;
    (*
      * Return an AVClass corresponding to the next potential
      * AVOptions-enabled child.
      *
      * The difference between child_next and this is that
      * child_next iterates over _already existing_ objects, while
      * child_class_next iterates over _all possible_ children.
    *)
    // const struct AVClass* (*child_class_next)(const struct AVClass *prev);
    child_class_next: TChild_class_next;
    (*
      * Category used for visualization (like color)
      * This is only set if the category is equal for all objects using this class.
      * available since version (51 << 16 | 56 << 8 | 100)
    *)
    category: TAVClassCategory;
    (*
      * Callback to return the category.
      * available since version (51 << 16 | 59 << 8 | 100)
    *)
    // AVClassCategory (*get_category)(void* ctx);
    get_category: TGet_category;
    (*
      // * Callback to return the supported/allowed ranges.
      // * available since version (52.12)
    *)
    // int (*query_ranges)(struct AVOptionRanges **, void *obj, const char *key, int flags);
    query_ranges: TQuery_ranges;
  end;

const
  (* Print no output. *)
  AV_LOG_QUIET = -8;
  (* Something went really wrong and we will crash now. *)
  AV_LOG_PANIC = 0;
  (*
    * Something went wrong and recovery is not possible.
    * For example, no header was found for a format which depends
    * on headers or an illegal combination of parameters is used.
  *)
  AV_LOG_FATAL = 8;
  (*
    * Something went wrong and cannot losslessly be recovered.
    * However, not all future data is affected.
  *)
  AV_LOG_ERROR = 16;
  (*
    * Something somehow does not look correct. This may or may not
    * lead to problems. An example would be the use of '-vstrict -2'.
  *)
  AV_LOG_WARNING = 24;
  (*
    * Standard information.
  *)
  AV_LOG_INFO = 32;
  (*
    * Detailed information.
  *)
  AV_LOG_VERBOSE = 40;
  (*
    * Stuff which is only useful for libav* developers.
  *)
  AV_LOG_DEBUG = 48;
  AV_LOG_MAX_OFFSET = (AV_LOG_DEBUG - AV_LOG_QUIET);
  (*
    * Send the specified message to the log if the level is less than or equal
    * to the current av_log_level. By default, all logging messages are sent to
    * stderr. This behavior can be altered by setting a different logging callback
    * function.
    * @see av_log_set_callback
    *
    * @param avcl A pointer to an arbitrary struct of which the first field is a
    *        pointer to an AVClass struct.
    * @param level The importance level of the message expressed using a @ref
    *        lavu_log_constants "Logging Constant".
    * @param fmt The format string (printf-compatible) that specifies how
    *        subsequent arguments are converted to output.
  *)

  // void av_log(void *avcl, int level, const char *fmt, ...) av_printf_format(3, 4);

  (*
    * Send the specified message to the log if the level is less than or equal
    * to the current av_log_level. By default, all logging messages are sent to
    * stderr. This behavior can be altered by setting a different logging callback
    * function.
    * @see av_log_set_callback
    *
    * @param avcl A pointer to an arbitrary struct of which the first field is a
    *        pointer to an AVClass struct.
    * @param level The importance level of the message expressed using a @ref
    *        lavu_log_constants "Logging Constant".
    * @param fmt The format string (printf-compatible) that specifies how
    *        subsequent arguments are converted to output.
    * @param vl The arguments referenced by the format string.
  *)
  // void av_vlog(void *avcl, int level, const char *fmt, va_list vl);
  (*
    * Get the current log level
    *
    * @see lavu_log_constants
    *
    * @return Current log level
  *)
  // int av_log_get_level(void);
function av_log_get_level: Integer; cdecl;

(*
  * Set the log level
  *
  * @see lavu_log_constants
  *
  * @param level Logging level
*)
// void av_log_set_level(int level);
procedure av_log_set_level(level: Integer); cdecl;

(*
  * Set the logging callback
  *
  * @note The callback must be thread safe, even if the application does not use
  *       threads itself as some codecs are multithreaded.
  *
  * @see av_log_default_callback
  *
  * @param callback A logging function with a compatible signature.
*)
// void av_log_set_callback(void (*callback)(void*, int, const char*, va_list));
Type
  Tav_log_set_callback = procedure(prt: Pointer; level: Integer; fmt: PAnsiChar; vl: PVA_LIST); cdecl varargs;

procedure av_log_set_callback(callbackproc: Tav_log_set_callback); cdecl;

(*
  * Default logging callback
  *
  * It prints the message to stderr, optionally colorizing it.
  *
  * @param avcl A pointer to an arbitrary struct of which the first field is a
  *        pointer to an AVClass struct.
  * @param level The importance level of the message expressed using a @ref
  *        lavu_log_constants "Logging Constant".
  * @param fmt The format string (printf-compatible) that specifies how
  *        subsequent arguments are converted to output.
  * @param ap The arguments referenced by the format string.
*)
// void av_log_default_callback(void* ptr, int level, const char* fmt, va_list vl);

(*
  * Return the context name
  *
  * @param  ctx The AVClass context
  *
  * @return The AVClass class_name
*)
// const char* av_default_item_name(void* ctx);
function av_default_item_name(clx: Pointer): PAnsiChar; cdecl;

// AVClassCategory av_default_get_category(void *ptr);
function av_default_get_category(ptr: Pointer): TAVClassCategory; cdecl;

(*
  * Format a line of log the same way as the default callback.
  * @param line          buffer to receive the formated line
  * @param line_size     size of the buffer
  * @param print_prefix  used to store whether the prefix must be printed;
  *                      must point to a persistent integer initially set to 1
*)
// void av_log_format_line(void *ptr, int level, const char *fmt, va_list vl,
// char *line, int line_size, int *print_prefix);
procedure av_log_format_line(ptr: Pointer; level: Integer; const fmt: PAnsiChar; vl: PVA_LIST; line: PAnsiChar;
  line_size: Integer; Var print_prefix: Integer); cdecl;

(*
  * av_dlog macros
  * Useful to print debug messages that shouldn't get compiled in normally.
*)
// #ifdef DEBUG
// #    define av_dlog(pctx, ...) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__)
// #else
// #    define av_dlog(pctx, ...) do { if (0) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__); } while (0)
// #endif

(*
  * Skip repeated messages, this requires the user app to use av_log() instead of
  * (f)printf as the 2 would otherwise interfere and lead to
  * "Last message repeated x times" messages below (f)printf messages with some
  * bad luck.
  * Also to receive the last, "last repeated" line if any, the user app must
  * call av_log(NULL, AV_LOG_QUIET, "%s", ""); at the end
*)
const
  AV_LOG_SKIP_REPEATED = 1;
  AV_LOG_PRINT_LEVEL = 2;

  // void av_log_set_flags(int arg);
procedure av_log_set_flags(arg: Integer); cdecl;
// int av_log_get_flags(void);
function av_log_get_flags: Integer; cdecl;

implementation

uses ffm.lib;

procedure av_log_set_flags; external avutil_dll;
function av_log_get_level; external avutil_dll;
procedure av_log_set_level; external avutil_dll;
function av_default_item_name; external avutil_dll;
function av_default_get_category; external avutil_dll;
function av_log_get_flags; external avutil_dll;
procedure av_log_set_callback; external avutil_dll;
procedure av_log_format_line; external avutil_dll;

end.
